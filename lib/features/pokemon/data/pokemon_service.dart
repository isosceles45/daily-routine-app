import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../domain/daily_pokemon.dart';

class PokemonService {
  const PokemonService(this._client);

  final ApiClient _client;

  /// Fetches one Pokémon. The species call supplies the Pokédex blurb but is
  /// optional — a missing flavour text is worth showing the Pokémon anyway.
  Future<ApiResult<DailyPokemon>> fetch(int id) async {
    final pokemon = await _client.getJson<Map<String, dynamic>>(
      '${ApiSources.pokeApi}/pokemon/$id',
      parse: (json) => json as Map<String, dynamic>,
    );

    if (pokemon case Failure<Map<String, dynamic>>(:final error)) {
      return Failure(error);
    }

    final species = await _client.getJson<Map<String, dynamic>>(
      '${ApiSources.pokeApi}/pokemon-species/$id',
      parse: (json) => json as Map<String, dynamic>,
    );

    return pokemon.map(
      (data) => DailyPokemon.fromApi(data, species: species.dataOrNull),
    );
  }
}
