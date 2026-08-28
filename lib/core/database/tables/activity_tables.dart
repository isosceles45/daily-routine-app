import 'package:drift/drift.dart';

/// An imported Wordle result (§6).
///
/// Note there is no column for the answer — the share text doesn't contain it
/// and the app must not store it.
class WordleResults extends Table {
  TextColumn get date => text()();
  IntColumn get wordleNumber => integer()();

  /// Guesses used, 1–6. Null means the puzzle was failed (`X/6`).
  IntColumn get score => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get hardMode => boolean().withDefault(const Constant(false))();

  /// The emoji grid, newline separated. Null when the share text omitted it.
  TextColumn get grid => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date};
}

class TriviaResults extends Table {
  TextColumn get date => text()();
  TextColumn get questionId => text()();
  TextColumn get selectedAnswer => text().nullable()();
  BoolColumn get answered => boolean().withDefault(const Constant(false))();
  BoolColumn get correct => boolean().withDefault(const Constant(false))();
  DateTimeColumn get answeredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

class CatQuantResults extends Table {
  TextColumn get date => text()();
  TextColumn get questionId => text()();
  TextColumn get topic => text()();
  TextColumn get difficulty => text()();
  IntColumn get selectedIndex => integer().nullable()();
  BoolColumn get answered => boolean().withDefault(const Constant(false))();
  BoolColumn get correct => boolean().withDefault(const Constant(false))();
  DateTimeColumn get answeredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

/// Generated surprise packs. Re-rolling appends rather than overwrites, so a
/// surprise never mutates the day's official content (§12).
class Surprises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
}
