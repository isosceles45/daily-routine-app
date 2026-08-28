import 'api_exception.dart';

/// Outcome of a remote call.
///
/// Offline is deliberately *not* a third case: it is an [ApiErrorKind] on the
/// failure, so every call site handles two branches instead of three while the
/// UI can still tell "you're offline" apart from "the server broke".
sealed class ApiResult<T> {
  const ApiResult();

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  ApiException? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final error) => error,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) =>
      switch (this) {
        Success<T>(:final data) => success(data),
        Failure<T>(:final error) => failure(error),
      };

  /// Transforms a successful payload, leaving failures untouched.
  ApiResult<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(:final data) => Success(transform(data)),
        Failure<T>(:final error) => Failure(error),
      };
}

final class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends ApiResult<T> {
  const Failure(this.error);
  final ApiException error;
}
