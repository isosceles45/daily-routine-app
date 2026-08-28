import '../../../core/database/database.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../../../core/utils/daily_seed.dart';
import '../domain/daily_pokemon.dart';
import 'pokemon_service.dart';

/// Deterministic Pokémon of the day, cached so the home screen never refetches
/// on rebuild (§10).
class PokemonRepository {
  const PokemonRepository(this._service, this._db);

  final PokemonService _service;
  final AppDatabase _db;

  static const _contentType = 'pokemon';

  /// `hash(date) % totalPokemon`, +1 because the Dex is 1-indexed.
  static int idForDate(String date) =>
      dailyIndex(date, _contentType, ApiSources.pokemonSpeciesCount) + 1;

  Future<ApiResult<DailyPokemon>> pokemonFor(String date) async {
    final cached = await _db.readContent(date, _contentType);
    if (cached != null) {
      try {
        return Success(DailyPokemon.fromJson(cached));
      } on Object {
        await _db.deleteContent(date, _contentType);
      }
    }

    final result = await _service.fetch(idForDate(date));

    if (result case Success<DailyPokemon>(:final data)) {
      await _db.writeContent(
        date: date,
        contentType: _contentType,
        source: 'PokéAPI',
        sourceId: '${data.id}',
        payload: data.toJson(),
      );
    }

    return result;
  }
}
