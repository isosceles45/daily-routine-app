import 'package:drift/drift.dart';

/// Simple key/value store for preferences and small bits of API state such as
/// the OpenTDB session token.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
