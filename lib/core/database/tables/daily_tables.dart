import 'package:drift/drift.dart';

/// One row per calendar day the app has seen.
class DailyStates extends Table {
  /// `yyyy-MM-dd`, local calendar date.
  TextColumn get date => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// Whether the "Happy New Day" greeting has been shown for this date (§5).
  BoolColumn get greetingShown =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {date};
}

/// Generic cache for every fetched daily payload (§21).
///
/// This one table is what makes offline work: repositories read today's row
/// before reaching for the network, and replay it forever after. Storing the
/// raw JSON rather than parsed columns means adding a field to a model never
/// requires a schema migration.
class DailyContents extends Table {
  TextColumn get date => text()();

  /// `trivia`, `pokemon`, `fun`, `japan`, `challenge`, `catQuant`…
  TextColumn get contentType => text()();

  /// Which API produced it, for attribution and debugging.
  TextColumn get source => text()();
  TextColumn get sourceId => text().nullable()();

  /// The raw JSON payload.
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date, contentType};
}

/// The daily challenge and whether it was marked done.
class Challenges extends Table {
  TextColumn get date => text()();

  /// The challenge itself. Named `prompt` rather than `text` because a column
  /// called `text` would shadow Drift's own `text()` column builder.
  TextColumn get prompt => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}
