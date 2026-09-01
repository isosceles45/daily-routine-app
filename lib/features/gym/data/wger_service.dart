import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../domain/workout.dart';

/// Reads exercises out of wger's open database.
///
/// wger keeps names and descriptions in per-language `translations` rather than
/// on the exercise itself, so `/exercise/` alone returns rows with no name at
/// all — `/exerciseinfo/` is the endpoint that carries both.
class WgerService {
  const WgerService(this._client);

  final ApiClient _client;

  /// wger's id for English.
  static const _english = 2;

  Future<ApiResult<List<Exercise>>> exercisesFor(
    int category, {
    int limit = 24,
  }) {
    return _client.getJson<List<Exercise>>(
      '${ApiSources.wger}/exerciseinfo/',
      query: {'format': 'json', 'category': category, 'limit': limit},
      parse: (json) {
        final results =
            (json as Map<String, dynamic>)['results'] as List<dynamic>? ??
            const [];

        final exercises = <Exercise>[];
        for (final raw in results) {
          final row = raw as Map<String, dynamic>;
          final translations =
              row['translations'] as List<dynamic>? ?? const [];

          Map<String, dynamic>? english;
          for (final t in translations) {
            final translation = t as Map<String, dynamic>;
            if (translation['language'] == _english) {
              english = translation;
              break;
            }
          }
          if (english == null) continue;

          final name = (english['name'] as String? ?? '').trim();
          if (name.isEmpty) continue;

          exercises.add(
            Exercise(
              id: row['id'] as int,
              name: name,
              description: stripHtml(english['description'] as String?),
            ),
          );
        }
        return exercises;
      },
    );
  }

  /// wger stores descriptions as HTML. Rendering the raw markup would put
  /// literal `<p>` tags on screen, so it is reduced to plain text here rather
  /// than pulling in an HTML widget for two paragraphs of prose.
  static String? stripHtml(String? html) {
    if (html == null) return null;

    final text = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();

    return text.isEmpty ? null : text;
  }
}
