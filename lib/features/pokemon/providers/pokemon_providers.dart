import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/providers.dart';
import '../data/pokemon_repository.dart';
import '../data/pokemon_service.dart';
import '../domain/daily_pokemon.dart';

final pokemonServiceProvider = Provider<PokemonService>(
  (ref) => PokemonService(ref.watch(apiClientProvider)),
);

final pokemonRepositoryProvider = Provider<PokemonRepository>(
  (ref) => PokemonRepository(
    ref.watch(pokemonServiceProvider),
    ref.watch(databaseProvider),
  ),
);

final pokemonOfTheDayProvider = FutureProvider<DailyPokemon>((ref) async {
  final date = ref.watch(currentDateProvider);
  final result = await ref.watch(pokemonRepositoryProvider).pokemonFor(date);
  return switch (result) {
    Success<DailyPokemon>(:final data) => data,
    Failure<DailyPokemon>(:final error) => throw error,
  };
});
