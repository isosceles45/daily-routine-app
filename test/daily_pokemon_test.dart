import 'package:daily_ritual/features/pokemon/data/pokemon_repository.dart';
import 'package:daily_ritual/features/pokemon/domain/daily_pokemon.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> pokemonPayload() => {
  'id': 133,
  'name': 'eevee',
  'height': 3,
  'weight': 65,
  'types': [
    {
      'slot': 1,
      'type': {'name': 'normal'},
    },
  ],
  'abilities': [
    {
      'ability': {'name': 'run-away'},
    },
    {
      'ability': {'name': 'adaptability'},
    },
  ],
  'stats': [
    {
      'base_stat': 55,
      'stat': {'name': 'hp'},
    },
    {
      'base_stat': 55,
      'stat': {'name': 'attack'},
    },
    {
      'base_stat': 50,
      'stat': {'name': 'defense'},
    },
    {
      'base_stat': 55,
      'stat': {'name': 'speed'},
    },
  ],
  'sprites': {
    'front_default': 'https://example.test/front.png',
    'other': {
      'official-artwork': {'front_default': 'https://example.test/artwork.png'},
    },
  },
};

Map<String, dynamic> speciesPayload() => {
  'flavor_text_entries': [
    {
      'flavor_text': 'Its genetic code is\nirregular.\fIt may mutate.',
      'language': {'name': 'ja'},
    },
    {
      'flavor_text': 'Its genetic code is\nirregular.\fIt may mutate.',
      'language': {'name': 'en'},
    },
  ],
};

void main() {
  test('parses the core fields', () {
    final p = DailyPokemon.fromApi(pokemonPayload());
    expect(p.id, 133);
    expect(p.displayName, 'Eevee');
    expect(p.types, ['normal']);
    expect(p.abilities, ['run-away', 'adaptability']);
    expect(p.dexNumber, '#133');
  });

  test('converts the API units into readable ones', () {
    // PokéAPI reports decimetres and hectograms, not metres and kilograms.
    final p = DailyPokemon.fromApi(pokemonPayload());
    expect(p.heightLabel, '0.3 m');
    expect(p.weightLabel, '6.5 kg');
  });

  test('prefers official artwork over the sprite', () {
    final p = DailyPokemon.fromApi(pokemonPayload());
    expect(p.artworkUrl, 'https://example.test/artwork.png');
  });

  test('falls back to the plain sprite when artwork is missing', () {
    final payload = pokemonPayload();
    (payload['sprites'] as Map<String, dynamic>).remove('other');
    expect(
      DailyPokemon.fromApi(payload).artworkUrl,
      'https://example.test/front.png',
    );
  });

  test('reads the four displayed stats in order', () {
    final p = DailyPokemon.fromApi(pokemonPayload());
    expect(p.stats.map((s) => s.label), ['HP', 'ATK', 'DEF', 'SPD']);
    expect(p.stats.map((s) => s.value), [55, 55, 50, 55]);
    expect(p.stats.first.fraction, closeTo(0.55, 0.001));
  });

  test('clamps an unusually high stat rather than overflowing the bar', () {
    const stat = PokemonStat('HP', 255);
    expect(stat.fraction, 1.0);
  });

  test('takes the English blurb and flattens cartridge line breaks', () {
    final p = DailyPokemon.fromApi(pokemonPayload(), species: speciesPayload());
    expect(p.flavorText, 'Its genetic code is irregular. It may mutate.');
  });

  test('a missing species is not fatal — the Pokémon still shows', () {
    final p = DailyPokemon.fromApi(pokemonPayload(), species: null);
    expect(p.flavorText, isNull);
    expect(p.displayName, 'Eevee');
  });

  test('survives a cache round-trip', () {
    final original = DailyPokemon.fromApi(
      pokemonPayload(),
      species: speciesPayload(),
    );
    final restored = DailyPokemon.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.flavorText, original.flavorText);
    expect(
      restored.stats.map((s) => s.value),
      original.stats.map((s) => s.value),
    );
  });

  group('daily selection', () {
    test('is stable for a date and inside the Dex range', () {
      for (var d = 1; d <= 28; d++) {
        final date = '2026-09-${d.toString().padLeft(2, '0')}';
        final id = PokemonRepository.idForDate(date);
        expect(
          id,
          inInclusiveRange(1, 1025),
          reason: 'the Dex is 1-indexed; id 0 does not exist',
        );
        expect(PokemonRepository.idForDate(date), id);
      }
    });

    test('varies across a month', () {
      final ids = {
        for (var d = 1; d <= 28; d++)
          PokemonRepository.idForDate(
            '2026-09-${d.toString().padLeft(2, '0')}',
          ),
      };
      expect(ids.length, greaterThan(20));
    });
  });
}
