import 'package:dio/dio.dart';

/// Why a request failed, in terms the UI can act on.
enum ApiErrorKind {
  /// No usable connection. Cached content should be shown instead.
  offline,

  /// The request was made but took too long.
  timeout,

  /// The server answered with a non-2xx status.
  http,

  /// The response arrived but didn't look like what we expected.
  parse,

  /// A valid, successful response that simply contained nothing usable.
  empty,

  unknown,
}

class ApiException implements Exception {
  const ApiException(this.kind, this.message, {this.statusCode, this.uri});

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;
  final String? uri;

  /// Whether retrying the identical request could plausibly succeed.
  bool get isRetryable => switch (kind) {
    ApiErrorKind.offline ||
    ApiErrorKind.timeout ||
    ApiErrorKind.unknown => true,
    ApiErrorKind.http => statusCode == null || statusCode! >= 500,
    ApiErrorKind.parse || ApiErrorKind.empty => false,
  };

  /// Short, non-technical text safe to put in front of the user.
  String get userMessage => switch (kind) {
    ApiErrorKind.offline => "You're offline.",
    ApiErrorKind.timeout => 'That took too long.',
    ApiErrorKind.http => "The source didn't respond properly.",
    ApiErrorKind.parse => "The source sent something unexpected.",
    ApiErrorKind.empty => 'Nothing came back.',
    ApiErrorKind.unknown => "That didn't work.",
  };

  factory ApiException.fromDio(DioException e) {
    final uri = e.requestOptions.uri.toString();
    return switch (e.type) {
      DioExceptionType.connectionError => ApiException(
        ApiErrorKind.offline,
        'Connection failed: ${e.message}',
        uri: uri,
      ),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.transformTimeout => ApiException(
        ApiErrorKind.timeout,
        'Timed out: ${e.message}',
        uri: uri,
      ),
      DioExceptionType.badResponse => ApiException(
        ApiErrorKind.http,
        'HTTP ${e.response?.statusCode}',
        statusCode: e.response?.statusCode,
        uri: uri,
      ),
      DioExceptionType.badCertificate => ApiException(
        ApiErrorKind.http,
        'Bad certificate',
        uri: uri,
      ),
      DioExceptionType.cancel => ApiException(
        ApiErrorKind.unknown,
        'Cancelled',
        uri: uri,
      ),
      DioExceptionType.unknown => ApiException(
        // Dio reports DNS failure as `unknown` wrapping a SocketException.
        e.error is Exception && '${e.error}'.contains('SocketException')
            ? ApiErrorKind.offline
            : ApiErrorKind.unknown,
        e.message ?? 'Request failed',
        uri: uri,
      ),
    };
  }

  @override
  String toString() => 'ApiException($kind): $message';
}
