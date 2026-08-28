import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/network/api_result.dart';
import '../domain/trivia_question.dart';
import 'trivia_service.dart';

/// Cache-first access to the day's question.
///
/// The question is written to `daily_content` the first time it is fetched and
/// replayed from there forever after, so refreshing the app never swaps today's
/// question (§7) and the card keeps working offline (§17).
class TriviaRepository {
  const TriviaRepository(this._service, this._db);

  final TriviaService _service;
  final AppDatabase _db;

  static const _contentType = 'trivia';
  static const _tokenKey = 'opentdb_token';

  Future<ApiResult<TriviaQuestion>> questionFor(String date) async {
    final cached = await _db.readContent(date, _contentType);
    if (cached != null) {
      try {
        return Success(TriviaQuestion.fromJson(cached));
      } on Object {
        // Shape changed under us — drop it and refetch rather than crash.
        await _db.deleteContent(date, _contentType);
      }
    }

    var token = await _db.getSetting(_tokenKey);
    token ??= await _requestAndStoreToken();

    var result = await _service.fetchDaily(date: date, token: token);

    // A stale token makes OpenTDB reject the request; get a fresh one once.
    if (result is Failure<TriviaQuestion> && token != null) {
      final fresh = await _requestAndStoreToken();
      if (fresh != null) {
        result = await _service.fetchDaily(date: date, token: fresh);
      }
    }

    // Still nothing — try the second source before giving up on the day.
    if (result is Failure<TriviaQuestion>) {
      final backup = await _service.fetchBackup(date: date);
      if (backup is Success<TriviaQuestion>) result = backup;
    }

    if (result case Success<TriviaQuestion>(:final data)) {
      await _db.writeContent(
        date: date,
        contentType: _contentType,
        source: data.source,
        sourceId: data.id,
        payload: data.toJson(),
      );
    }

    return result;
  }

  Future<String?> _requestAndStoreToken() async {
    final token = await _service.requestToken();
    if (token != null) await _db.setSetting(_tokenKey, token);
    return token;
  }

  Future<TriviaResult?> resultFor(String date) {
    return (_db.select(_db.triviaResults)..where((t) => t.date.equals(date)))
        .getSingleOrNull();
  }

  Stream<TriviaResult?> watchResult(String date) {
    return (_db.select(_db.triviaResults)..where((t) => t.date.equals(date)))
        .watchSingleOrNull();
  }

  Future<void> saveAnswer({
    required String date,
    required TriviaQuestion question,
    required String answer,
  }) async {
    await _db.into(_db.triviaResults).insertOnConflictUpdate(
          TriviaResultsCompanion.insert(
            date: date,
            questionId: question.id,
            selectedAnswer: Value(answer),
            answered: const Value(true),
            correct: Value(question.isCorrect(answer)),
            answeredAt: Value(DateTime.now()),
          ),
        );
  }
}
