import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/cat_question.dart';
import 'cat_question_source.dart';

class CatRepository {
  const CatRepository(this._chain, this._db);

  final CatQuestionChain _chain;
  final AppDatabase _db;

  static const _contentType = 'catQuant';

  /// Today's question, cached so the day's problem never changes underfoot —
  /// and so a verified question stays available offline.
  Future<CatQuestion?> questionFor(String date) async {
    final cached = await _db.readContent(date, _contentType);
    if (cached != null) {
      try {
        return CatQuestion.fromJson(cached);
      } on Object {
        await _db.deleteContent(date, _contentType);
      }
    }

    final question = await _chain.questionFor(date);
    if (question == null) return null;

    await _db.writeContent(
      date: date,
      contentType: _contentType,
      source: question.source.label,
      sourceId: question.id,
      payload: question.toJson(),
    );
    return question;
  }

  /// Clears today's cached question so `TRY AGAIN` can genuinely try again.
  Future<void> invalidate(String date) => _db.deleteContent(date, _contentType);

  Stream<CatQuantResult?> watchResult(String date) {
    return (_db.select(
      _db.catQuantResults,
    )..where((t) => t.date.equals(date))).watchSingleOrNull();
  }

  Future<void> saveAnswer({
    required String date,
    required CatQuestion question,
    required int selectedIndex,
  }) {
    return _db
        .into(_db.catQuantResults)
        .insertOnConflictUpdate(
          CatQuantResultsCompanion.insert(
            date: date,
            questionId: question.id,
            topic: question.topic,
            difficulty: question.difficulty,
            selectedIndex: Value(selectedIndex),
            answered: const Value(true),
            correct: Value(question.isCorrect(selectedIndex)),
            answeredAt: Value(DateTime.now()),
          ),
        );
  }

  Future<List<CatQuantResult>> allResults() =>
      _db.select(_db.catQuantResults).get();

  Stream<List<CatQuantResult>> watchAllResults() =>
      _db.select(_db.catQuantResults).watch();
}

/// How often the user has got the CAT question right.
///
/// This replaces the canvas's "26% solved this correctly" — a global figure
/// would need a backend and a userbase, and inventing one would be a lie.
class CatAccuracy {
  const CatAccuracy({required this.answered, required this.correct});

  static const empty = CatAccuracy(answered: 0, correct: 0);

  final int answered;
  final int correct;

  double get percentage => answered == 0 ? 0 : correct / answered * 100;

  String get label =>
      answered == 0 ? 'First one' : '${percentage.round()}% correct so far';

  static CatAccuracy from(List<CatQuantResult> results) {
    final answered = results.where((r) => r.answered).toList();
    return CatAccuracy(
      answered: answered.length,
      correct: answered.where((r) => r.correct).length,
    );
  }
}
