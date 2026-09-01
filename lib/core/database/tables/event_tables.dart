import 'package:drift/drift.dart';

/// A date the user is counting down to — a trip, an exam, a birthday.
///
/// Deliberately not a todo with a due date: a todo is something you finish,
/// an event is something that arrives whether you act or not. Conflating them
/// would mean "completing" your holiday.
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();

  /// The day it happens, local calendar date as `yyyy-MM-dd`.
  ///
  /// Stored as text rather than DateTime for the same reason every other date
  /// in this app is: a countdown is measured in calendar days, and a UTC
  /// instant would tip over a day early or late depending on the timezone.
  TextColumn get date => text()();

  TextColumn get note => text().nullable()();

  /// Optional emoji shown on the countdown card.
  TextColumn get emoji => text().nullable()();

  /// Pinned events lead the list and surface on Today.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
