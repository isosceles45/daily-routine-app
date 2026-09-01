import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../../../core/utils/daily_seed.dart';
import '../domain/place_entry.dart';

/// Where place-of-the-day content comes from.
///
/// §11 asks that the data source be replaceable without touching UI code, so
/// everything above this line deals only in [PlaceEntry].
abstract class PlaceSource {
  const PlaceSource();

  /// [seedKey] makes the choice reproducible. Japan-of-the-day passes the
  /// date; Surprise Me passes a random token so it re-rolls.
  Future<PlaceEntry?> entryFor(String seedKey);
}

/// Wikipedia-backed implementation.
///
/// Picks a curated category for the day, enumerates its members through the
/// MediaWiki action API, then walks candidates until one has a summary good
/// enough to show. Both the choice and the content come from the API; only the
/// list of categories is ours.
class WikipediaPlaceSource extends PlaceSource {
  const WikipediaPlaceSource(this._client);

  final ApiClient _client;

  /// Meta-articles that live in these categories but make dull discoveries.
  static const _skipPrefixes = [
    'List of',
    'Index of',
    'Outline of',
    'Glossary',
    'Timeline of',
    'ISO ',
  ];

  /// A summary shorter than this is a stub — not worth a day.
  static const _minExtractLength = 180;

  /// How many candidates to try before giving up on the day.
  static const _maxCandidates = 8;

  static Options get _options =>
      Options(headers: const {'User-Agent': ApiSources.userAgent});

  @override
  Future<PlaceEntry?> entryFor(String seedKey) async {
    // Try a couple of categories, in case the first is having a bad day.
    for (var attempt = 0; attempt < 3; attempt++) {
      final category =
          PlaceCategory.all[dailyIndex(
            seedKey,
            'japan-category-$attempt',
            PlaceCategory.all.length,
          )];

      final titles = await _membersOf(category);
      if (titles.isEmpty) continue;

      // Walk deterministically from the day's offset, so the same date always
      // lands on the same entry, but a rejected candidate has a successor.
      final start = dailyIndex(seedKey, 'japan-entry', titles.length);
      for (var i = 0; i < titles.length && i < _maxCandidates; i++) {
        final title = titles[(start + i) % titles.length];
        final entry = await _summaryOf(title, category);
        if (entry != null) return entry;
      }
    }
    return null;
  }

  Future<List<String>> _membersOf(PlaceCategory category) async {
    final result = await _client.getJson<List<String>>(
      ApiSources.wikipediaAction,
      options: _options,
      query: {
        'action': 'query',
        'list': 'categorymembers',
        'cmtitle': 'Category:${category.wikiCategory}',
        'cmlimit': '100',
        // Namespace 0 and type page exclude subcategories and talk pages.
        'cmnamespace': '0',
        'cmtype': 'page',
        'format': 'json',
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final members =
            (map['query'] as Map<String, dynamic>?)?['categorymembers']
                as List<dynamic>?;
        if (members == null) return const <String>[];

        return members
            .map((m) => (m as Map<String, dynamic>)['title'] as String)
            .where((t) => !_skipPrefixes.any(t.startsWith))
            .toList(growable: false);
      },
    );

    return result.dataOrNull ?? const [];
  }

  /// Fetches a page summary and judges whether it is worth showing.
  Future<PlaceEntry?> _summaryOf(String title, PlaceCategory category) async {
    final result = await _client.getJson<PlaceEntry?>(
      '${ApiSources.wikipediaSummary}/${Uri.encodeComponent(title)}',
      options: _options,
      parse: (json) {
        final map = json as Map<String, dynamic>;

        // A disambiguation page is a signpost, not a subject.
        if (map['type'] != 'standard') return null;

        final extract = (map['extract'] as String? ?? '').trim();
        if (extract.length < _minExtractLength) return null;

        // The canvas puts a hero image at the top of this card, so an entry
        // without one can't be rendered as designed. That makes "has a photo"
        // a genuine requirement rather than an arbitrary quality bar — and it
        // happens to filter out the thin, obscure pages too.
        final thumbnail = map['thumbnail'] as Map<String, dynamic>?;
        final original = map['originalimage'] as Map<String, dynamic>?;
        final imageUrl =
            original?['source'] as String? ?? thumbnail?['source'] as String?;
        if (imageUrl == null) return null;

        final pages = map['content_urls'] as Map<String, dynamic>?;
        final desktop = pages?['desktop'] as Map<String, dynamic>?;

        return PlaceEntry(
          title: map['title'] as String? ?? title,
          extract: extract,
          category: category.label,
          region: category.region,
          description: map['description'] as String?,
          imageUrl: imageUrl,
          pageUrl: desktop?['page'] as String?,
        );
      },
    );

    return switch (result) {
      Success<PlaceEntry?>(:final data) => data,
      Failure<PlaceEntry?>() => null,
    };
  }
}
