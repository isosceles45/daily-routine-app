import 'package:daily_ritual/features/animals/domain/daily_fun.dart';
import 'package:daily_ritual/features/challenges/domain/daily_challenge.dart';
import 'package:daily_ritual/features/places/domain/place_entry.dart';
import 'package:daily_ritual/features/pokemon/domain/daily_pokemon.dart';
import 'package:flutter_test/flutter_test.dart';

const japan = PlaceEntry(
  title: 'Kenroku-en',
  extract: 'A garden. In Kanazawa. Very old.',
  category: 'Gardens',
  region: 'Japan',
);

const pokemon = DailyPokemon(
  id: 133,
  name: 'eevee',
  types: ['normal'],
  abilities: ['run-away'],
  heightDecimetres: 3,
  weightHectograms: 65,
  artworkUrl: null,
  stats: [],
);

const fun = DailyFun(kind: FunKind.joke, source: 'JokeAPI', text: 'Ha.');

void main() {
  test('always returns a challenge, even with nothing loaded', () {
    // The network being down must never leave the day without one.
    final c = ChallengeGenerator.build(date: '2026-08-26');
    expect(c.text.trim(), isNotEmpty);
  });

  test('is stable for a given date', () {
    final a = ChallengeGenerator.build(date: '2026-08-26', place: japan);
    final b = ChallengeGenerator.build(date: '2026-08-26', place: japan);
    expect(a.text, b.text);
  });

  test('varies across dates', () {
    final texts = {
      for (var d = 1; d <= 28; d++)
        ChallengeGenerator.build(
          date: '2026-09-${d.toString().padLeft(2, '0')}',
          place: japan,
          pokemon: pokemon,
          fun: fun,
        ).text,
    };
    expect(texts.length, greaterThan(3));
  });

  test('draws on the day’s own content when it is available', () {
    // Across a month, at least some challenges should name what is on screen.
    final referencing = <String>{};
    for (var d = 1; d <= 28; d++) {
      final c = ChallengeGenerator.build(
        date: '2026-10-${d.toString().padLeft(2, '0')}',
        place: japan,
        pokemon: pokemon,
        fun: fun,
      );
      if (c.text.contains('Kenroku-en') || c.text.contains('Eevee')) {
        referencing.add(c.text);
      }
    }
    expect(referencing, isNotEmpty);
  });

  test('never names content that did not load', () {
    for (var d = 1; d <= 28; d++) {
      final c = ChallengeGenerator.build(
        date: '2026-11-${d.toString().padLeft(2, '0')}',
      );
      expect(c.text, isNot(contains('Kenroku-en')));
      expect(c.text, isNot(contains('Eevee')));
      expect(c.origin, isNull);
    }
  });

  test('records which section it came from', () {
    final withContent = [
      for (var d = 1; d <= 28; d++)
        ChallengeGenerator.build(
          date: '2026-12-${d.toString().padLeft(2, '0')}',
          place: japan,
          pokemon: pokemon,
        ),
    ];
    expect(
      withContent.any((c) => c.origin == 'Japan' || c.origin == 'Pokémon'),
      isTrue,
    );
  });

  test('survives a round-trip', () {
    final original = ChallengeGenerator.build(date: '2026-08-26', place: japan);
    final restored = DailyChallenge.fromJson(original.toJson());
    expect(restored.text, original.text);
    expect(restored.origin, original.origin);
  });
}
