import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

/// Local-only countdown storage. Like todos, it never touches the network.
class EventRepository {
  const EventRepository(this._db);

  final AppDatabase _db;

  static final _random = Random();

  static String newId() {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 32).toRadixString(36);
    return 'evt-$stamp-$salt';
  }

  Stream<List<Event>> watchAll() => (_db.select(
    _db.events,
  )..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();

  Future<Event> add({
    required String title,
    required String date,
    String? note,
    String? emoji,
    bool pinned = false,
  }) async {
    final now = DateTime.now();
    final row = EventsCompanion.insert(
      id: newId(),
      title: title.trim(),
      date: date,
      note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
      emoji: Value(emoji),
      pinned: Value(pinned),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.events).insert(row);
    return (_db.select(
      _db.events,
    )..where((t) => t.id.equals(row.id.value))).getSingle();
  }

  Future<void> update(
    String id, {
    String? title,
    String? date,
    String? note,
    String? emoji,
    bool? pinned,
  }) {
    return (_db.update(_db.events)..where((t) => t.id.equals(id))).write(
      EventsCompanion(
        title: title == null ? const Value.absent() : Value(title.trim()),
        date: date == null ? const Value.absent() : Value(date),
        note: note == null ? const Value.absent() : Value(note.trim()),
        emoji: emoji == null ? const Value.absent() : Value(emoji),
        pinned: pinned == null ? const Value.absent() : Value(pinned),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> remove(String id) =>
      (_db.delete(_db.events)..where((t) => t.id.equals(id))).go();
}
