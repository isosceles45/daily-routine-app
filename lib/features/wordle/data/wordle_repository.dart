import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/wordle_share.dart';

/// Local storage for imported Wordle results.
///
/// There is no service layer here on purpose: nothing is fetched. The NYT page
/// is opened externally and the result comes back through the clipboard (§6).
class WordleRepository {
  const WordleRepository(this._db);

  final AppDatabase _db;

  Stream<List<WordleResult>> watchAll() {
    return (_db.select(
      _db.wordleResults,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  }

  Future<List<WordleResult>> all() {
    return (_db.select(
      _db.wordleResults,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  }

  Stream<WordleResult?> watchFor(String date) {
    return (_db.select(
      _db.wordleResults,
    )..where((t) => t.date.equals(date))).watchSingleOrNull();
  }

  Future<WordleResult?> forDate(String date) {
    return (_db.select(
      _db.wordleResults,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  /// Saves a parsed share. Re-importing the same day overwrites it, so pasting
  /// twice can't inflate the stats.
  Future<void> save(WordleShare share) {
    return _db
        .into(_db.wordleResults)
        .insertOnConflictUpdate(
          WordleResultsCompanion.insert(
            date: share.date,
            wordleNumber: share.number,
            score: Value(share.score),
            completed: Value(share.completed),
            hardMode: Value(share.hardMode),
            grid: Value(share.grid.isEmpty ? null : share.grid.join('\n')),
            importedAt: DateTime.now(),
          ),
        );
  }

  Future<void> remove(String date) =>
      (_db.delete(_db.wordleResults)..where((t) => t.date.equals(date))).go();
}
