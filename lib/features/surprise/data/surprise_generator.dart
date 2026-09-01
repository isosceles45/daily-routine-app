import 'dart:math';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../../animals/data/fun_service.dart';
import '../../animals/domain/daily_fun.dart';
import '../../pokemon/data/pokemon_service.dart';
import '../domain/surprise_pack.dart';

/// Composes several public APIs into one throwaway experience (§12).
///
/// Each source is independently replaceable and independently allowed to fail:
/// the pack is assembled from whatever came back. Nothing here touches the
/// day's official content or its cache — a surprise must never change what
/// Today shows.
class SurpriseGenerator {
  const SurpriseGenerator({
    required this.client,
    required this.funService,
    required this.pokemonService,
  });

  final ApiClient client;
  final FunService funService;
  final PokemonService pokemonService;

  static final _random = Random();

  Future<SurprisePack> generate() async {
    // Fired together — the pack is only as slow as its slowest source, and one
    // timing out doesn't hold up the rest.
    //
    // Place of the day deliberately has no slot here: it is the one section
    // worth arriving at deliberately rather than being handed at random.
    final results = await Future.wait([
      _animal(),
      _pokemon(),
      _fact(),
      _joke(),
    ]);

    return SurprisePack(
      slots: results.whereType<SurpriseSlot>().toList(growable: false),
      challenge: _challenge(),
    );
  }

  Future<SurpriseSlot?> _animal() async {
    final kind = _random.nextBool() ? FunKind.cat : FunKind.dog;
    final result = await funService.fetch(kind);

    return switch (result) {
      Success<DailyFun>(:final data) => SurpriseSlot(
        label: "Today's animal",
        value: data.kind.label,
        imageUrl: data.imageUrl,
      ),
      Failure<DailyFun>() => null,
    };
  }

  Future<SurpriseSlot?> _pokemon() async {
    final id = _random.nextInt(ApiSources.pokemonSpeciesCount) + 1;
    final result = await pokemonService.fetch(id);

    return result.when(
      success: (p) => SurpriseSlot(
        label: 'Pokémon',
        value: p.displayName,
        imageUrl: p.artworkUrl,
      ),
      failure: (_) => null,
    );
  }

  Future<SurpriseSlot?> _fact() async {
    final result = await client.getJson<String?>(
      ApiSources.uselessFacts,
      query: const {'language': 'en'},
      parse: (json) => (json as Map<String, dynamic>)['text'] as String?,
    );

    final text = result.dataOrNull;
    if (text == null || text.isEmpty) return null;
    return SurpriseSlot(label: 'Did you know?', value: text);
  }

  Future<SurpriseSlot?> _joke() async {
    final result = await client.getJson<String?>(
      '${ApiSources.jokeApi}/Any',
      query: const {
        'type': 'single',
        'safe-mode': '',
        'blacklistFlags': 'racist,sexist,explicit',
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        if (map['error'] == true) return null;
        return map['joke'] as String?;
      },
    );

    final joke = result.dataOrNull;
    if (joke == null || joke.isEmpty) return null;
    return SurpriseSlot(label: 'A joke', value: joke);
  }

  /// Small, self-contained dares. Unlike the daily challenge these can't be
  /// derived from today's content, because a surprise deliberately isn't
  /// today's content.
  String _challenge() {
    const challenges = [
      'Learn how to say "thank you" in a language you do not speak.',
      'Look up where the nearest river to you starts.',
      'Find out one thing that happened on this date.',
      'Text someone you have not spoken to in a month.',
      'Learn the name of one cloud type and go find it.',
      'Read the first paragraph of a Wikipedia article at random.',
    ];
    return challenges[_random.nextInt(challenges.length)];
  }
}
