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
    FunKind.fox => _fox(),
    FunKind.duck => _duck(),
    FunKind.bunny => _bunny(),
    FunKind.joke => _joke(safe: true),
    FunKind.darkJoke => _joke(safe: false),
    FunKind.weirdFact => _weirdFact(),
  };

  /// The species that have an image API but no fact API of their own. They
  /// borrow Useless Facts so the card still has something to read, and the
  /// source line credits both honestly.
  Future<ApiResult<DailyFun>> _animalWithBorrowedFact({
    required FunKind kind,
    required String source,
    required Future<ApiResult<String?>> Function() image,
  }) async {
    final picture = await image();

    final fact = await _client.getJson<String?>(
      ApiSources.uselessFacts,
      query: const {'language': 'en'},
      parse: (json) => (json as Map<String, dynamic>)['text'] as String?,
    );

    return _combine(
      kind: kind,
      source: '$source · Useless Facts',
      imageUrl: picture.dataOrNull,
      text: fact.dataOrNull,
      fallbackError: picture.errorOrNull ?? fact.errorOrNull,
    );
  }

  Future<ApiResult<DailyFun>> _fox() => _animalWithBorrowedFact(
    kind: FunKind.fox,
    source: 'RandomFox',
    image: () => _client.getJson<String?>(
      ApiSources.foxImage,
      parse: (json) => (json as Map<String, dynamic>)['image'] as String?,
    ),
  );

  Future<ApiResult<DailyFun>> _duck() => _animalWithBorrowedFact(
    kind: FunKind.duck,
    source: 'random-d.uk',
    image: () => _client.getJson<String?>(
      ApiSources.duckImage,
      parse: (json) {
        final url = (json as Map<String, dynamic>)['url'] as String?;
        // random-d.uk hands back an http:// URL even over TLS; Android blocks
        // cleartext by default, so it would silently render nothing.
        return url == null ? null : _https(url);
      },
    ),
  );

  Future<ApiResult<DailyFun>> _bunny() => _animalWithBorrowedFact(
    kind: FunKind.bunny,
    source: 'bunnies.io',
    image: () => _client.getJson<String?>(
      ApiSources.bunnyImage,
      query: const {'media': 'gif,poster'},
      parse: (json) {
        final media =
            (json as Map<String, dynamic>)['media'] as Map<String, dynamic>?;
        if (media == null) return null;
        // The gif is the point; the poster is a still fallback for when the
        // animation is missing.
        final url = (media['gif'] ?? media['poster']) as String?;
        return url == null ? null : _https(url);
      },
    ),
  );

  static String _https(String url) =>
      url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;

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
