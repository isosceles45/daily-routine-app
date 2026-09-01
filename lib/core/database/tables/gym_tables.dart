import 'package:drift/drift.dart';

/// One weekday of the user's training split.
///
/// Keyed by weekday rather than by date because a split is a repeating shape,
/// not a calendar. `DateTime.monday` … `DateTime.sunday`, so 1–7.
class WorkoutSlots extends Table {
  IntColumn get weekday => integer()();

  /// What that day trains — a wger category name such as "Chest", or "Rest".
  TextColumn get focus => text()();

  /// The wger category id this focus maps to, so suggestions can be fetched.
  /// Null for a rest day, or a focus the user typed that maps to nothing.
  IntColumn get wgerCategory => integer().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {weekday};
}

/// A session that actually happened.
class WorkoutLogs extends Table {
  TextColumn get date => text()();
  TextColumn get focus => text()();

  /// Exercise names the user ticked off, JSON-encoded.
  TextColumn get done => text().nullable()();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}
