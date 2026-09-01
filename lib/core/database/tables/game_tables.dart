import 'package:drift/drift.dart';

/// One finished run of a game.
///
/// Append-only: every run is kept so the history and personal bests are
/// derived from real rows rather than a single mutable "high score" that
/// cannot be audited.
class GameScores extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Matches `GameKind.name`.
  TextColumn get game => text()();

  /// Higher is better for every game here, which is what lets one table serve
  /// all of them.
  IntColumn get score => integer()();

  /// Per-game extras — difficulty, duration, accuracy — as JSON.
  TextColumn get detail => text().nullable()();

  /// The calendar date the run happened, for per-day history.
  TextColumn get date => text()();

  DateTimeColumn get playedAt => dateTime()();
}

/// An unfinished game, so closing the app mid-puzzle does not throw it away.
///
/// One row per game: you can have a Sudoku and a 2048 in progress at once,
/// but not two Sudokus.
class PuzzleStates extends Table {
  /// Matches `GameKind.name`.
  TextColumn get game => text()();

  /// The whole board, JSON-encoded. Kept opaque for the same reason
  /// `daily_contents` is: a game changing its representation must not need a
  /// schema migration.
  TextColumn get payload => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {game};
}
