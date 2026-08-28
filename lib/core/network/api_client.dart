import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'api_result.dart';

/// Thin wrapper over Dio. Services depend on this; widgets never do (§18).
///
/// Responsibilities are deliberately narrow: timeouts, bounded retry, and
/// turning every possible throw into an [ApiResult]. Caching lives one layer
/// up in the repositories, because only they know what "today's content" means.
class ApiClient {
  ApiClient({Dio? dio, this.maxRetries = 2})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
              headers: const {'Accept': 'application/json'},
              // We inspect status codes ourselves rather than letting Dio throw
              // on 4xx, so `validateStatus` stays permissive.
              validateStatus: (_) => true,
              responseType: ResponseType.json,
            ),
          );

  final Dio _dio;
  final int maxRetries;

  /// Fetches [url] and hands the decoded body to [parse].
  ///
  /// [parse] may throw freely — anything it throws becomes an
  /// [ApiErrorKind.parse] failure rather than crashing the caller.
  Future<ApiResult<T>> getJson<T>(
    String url, {
    Map<String, dynamic>? query,
    required T Function(dynamic json) parse,
    Options? options,
  }) async {
    var attempt = 0;

    while (true) {
      try {
        final response = await _dio.get<dynamic>(
          url,
          queryParameters: query,
          options: options,
        );

        final status = response.statusCode ?? 0;
        if (status < 200 || status >= 300) {
          final failure = ApiException(
            ApiErrorKind.http,
            'HTTP $status for $url',
            statusCode: status,
            uri: url,
          );
          // Only server-side faults are worth repeating; a 404 will stay a 404.
          if (failure.isRetryable && attempt < maxRetries) {
            attempt++;
            await _backoff(attempt);
            continue;
          }
          return Failure(failure);
        }

        final body = response.data;
        if (body == null || (body is String && body.trim().isEmpty)) {
          return Failure(
            ApiException(ApiErrorKind.empty, 'Empty body from $url', uri: url),
          );
        }

        try {
          return Success(parse(body));
        } catch (e) {
          return Failure(
            ApiException(
              ApiErrorKind.parse,
              'Could not parse $url: $e',
              uri: url,
            ),
          );
        }
      } on DioException catch (e) {
        final failure = ApiException.fromDio(e);
        if (failure.isRetryable && attempt < maxRetries) {
          attempt++;
          await _backoff(attempt);
          continue;
        }
        return Failure(failure);
      } catch (e) {
        return Failure(ApiException(ApiErrorKind.unknown, '$e', uri: url));
      }
    }
  }

  /// Fetches a plain-text body, for endpoints that don't return JSON.
  Future<ApiResult<String>> getText(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    return getJson<String>(
      url,
      query: query,
      options: Options(responseType: ResponseType.plain),
      parse: (json) => json.toString(),
    );
  }

  /// Exponential backoff with jitter, so several cards failing at once don't
  /// retry in lockstep and hammer the same host.
  Future<void> _backoff(int attempt) {
    final base = 400 * pow(2, attempt - 1).toInt();
    final jitter = Random().nextInt(150);
    return Future<void>.delayed(Duration(milliseconds: base + jitter));
  }

  void close() => _dio.close(force: true);
}
