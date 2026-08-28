import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/api_sources.dart';
import '../domain/daily_fun.dart';

/// Fetches the day's fun content from whichever public APIs suit the flavour.
///
/// Image and text are fetched independently and neither is required: a cat
/// photo with no fact still beats an empty card.
class FunService {
  const FunService(this._client);

  final ApiClient _client;

  Future<ApiResult<DailyFun>> fetch(FunKind kind) => switch (kind) {
    FunKind.cat => _cat(),
    FunKind.dog => _dog(),
    FunKind.joke => _joke(safe: true),
    FunKind.darkJoke => _joke(safe: false),
    FunKind.weirdFact => _weirdFact(),
  };

  Future<ApiResult<DailyFun>> _cat() async {
    final image = await _client.getJson<String?>(
      ApiSources.cataas,
      query: const {'json': 'true'},
      parse: (json) => (json as Map<String, dynamic>)['url'] as String?,
    );

    final fact = await _client.getJson<String?>(
      ApiSources.catFacts,
      parse: (json) => (json as Map<String, dynamic>)['fact'] as String?,
    );

    return _combine(
      kind: FunKind.cat,
      source: 'Cataas · Cat Facts',
      imageUrl: image.dataOrNull,
      text: fact.dataOrNull,
      fallbackError: image.errorOrNull ?? fact.errorOrNull,
    );
  }

  Future<ApiResult<DailyFun>> _dog() async {
    final image = await _client.getJson<String?>(
      ApiSources.dogImage,
      parse: (json) => (json as Map<String, dynamic>)['message'] as String?,
    );

    final fact = await _client.getJson<String?>(
      ApiSources.uselessFacts,
      query: const {'language': 'en'},
      parse: (json) => (json as Map<String, dynamic>)['text'] as String?,
    );

    return _combine(
      kind: FunKind.dog,
      source: 'dog.ceo · Useless Facts',
      imageUrl: image.dataOrNull,
      text: fact.dataOrNull,
      fallbackError: image.errorOrNull ?? fact.errorOrNull,
    );
  }

  Future<ApiResult<DailyFun>> _joke({required bool safe}) async {
    final result = await _client.getJson<String?>(
      '${ApiSources.jokeApi}/${safe ? 'Any' : 'Dark'}',
      query: {
        'type': 'single',
        if (safe) 'safe-mode': '',
        // Dark is one thing; slurs are another. Excluded either way.
        'blacklistFlags': 'racist,sexist,explicit',
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        if (map['error'] == true) {
          throw FormatException('JokeAPI: ${map['message']}');
        }
        return map['joke'] as String?;
      },
    );

    return switch (result) {
      Success<String?>(:final data) when data != null && data.isNotEmpty =>
        Success(
          DailyFun(
            kind: safe ? FunKind.joke : FunKind.darkJoke,
            source: 'JokeAPI',
            text: data,
          ),
        ),
      Success<String?>() => const Failure(
        ApiException(ApiErrorKind.empty, 'JokeAPI returned no joke'),
      ),
      Failure<String?>(:final error) => Failure(error),
    };
  }

  Future<ApiResult<DailyFun>> _weirdFact() async {
    final result = await _client.getJson<String?>(
      ApiSources.uselessFacts,
      query: const {'language': 'en'},
      parse: (json) => (json as Map<String, dynamic>)['text'] as String?,
    );

    return switch (result) {
      Success<String?>(:final data) when data != null && data.isNotEmpty =>
        Success(
          DailyFun(
            kind: FunKind.weirdFact,
            source: 'Useless Facts',
            text: data,
          ),
        ),
      Success<String?>() => const Failure(
        ApiException(ApiErrorKind.empty, 'No fact returned'),
      ),
      Failure<String?>(:final error) => Failure(error),
    };
  }

  /// Succeeds if *either* half arrived; fails only when both did not.
  ApiResult<DailyFun> _combine({
    required FunKind kind,
    required String source,
    required String? imageUrl,
    required String? text,
    required ApiException? fallbackError,
  }) {
    if (imageUrl == null && (text == null || text.isEmpty)) {
      return Failure(
        fallbackError ??
            const ApiException(ApiErrorKind.empty, 'No fun content returned'),
      );
    }
    return Success(
      DailyFun(kind: kind, source: source, imageUrl: imageUrl, text: text),
    );
  }
}
