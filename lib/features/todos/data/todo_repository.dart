import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/dates/daily_date_service.dart';
import '../domain/todo.dart';

/// Local-only todo storage. No account, no backend, no network (§13) — which
/// is exactly why this is the one section of the app that can never fail.
class TodoRepository {
  const TodoRepository(this._db);

  final AppDatabase _db;

  static final _random = Random();

  /// Time-ordered, collision-resistant enough for a single-user local app.
  static String newId() {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 32).toRadixString(36);
    return '$stamp-$salt';
  }

  Stream<List<Todo>> watchAll() {
    return (_db.select(_db.todos)..orderBy([
          // Unfinished first, then most urgent, then oldest.
          (t) => OrderingTerm.asc(t.completed),
          (t) => OrderingTerm.desc(t.priority),
          (t) => OrderingTerm.asc(t.createdAt),
        ]))
        .watch();
  }

  Future<Todo> add({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.normal,
    DateTime? dueDate,
    DateTime? reminderAt,
    String? category,
  }) async {
    final now = DateTime.now();
    final row = TodosCompanion.insert(
      id: newId(),
      title: title.trim(),
      description: Value(description),
      priority: Value(priority.value),
      createdAt: now,
      updatedAt: now,
      dueDate: Value(dueDate),
      reminderAt: Value(reminderAt),
      category: Value(category),
    );
    await _db.into(_db.todos).insert(row);
    return (_db.select(
      _db.todos,
    )..where((t) => t.id.equals(row.id.value))).getSingle();
  }

  Future<void> edit(
    String id, {
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
    DateTime? reminderAt,
    String? category,
    bool clearDueDate = false,
    bool clearReminder = false,
  }) {
    return (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        title: title == null ? const Value.absent() : Value(title.trim()),
        // An empty string here means "the user cleared the notes", which is a
        // different intent from omitting the argument entirely.
        description: description == null
            ? const Value.absent()
            : Value(description.trim().isEmpty ? null : description.trim()),
        priority: priority == null
            ? const Value.absent()
            : Value(priority.value),
        dueDate: clearDueDate
            ? const Value(null)
            : (dueDate == null ? const Value.absent() : Value(dueDate)),
        reminderAt: clearReminder
            ? const Value(null)
            : (reminderAt == null ? const Value.absent() : Value(reminderAt)),
        category: category == null ? const Value.absent() : Value(category),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setCompleted(String id, bool completed) {
    final now = DateTime.now();
    return (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        completed: Value(completed),
        completedAt: Value(completed ? now : null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> remove(String id) =>
      (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();

  /// Which group a todo belongs to, relative to [today] (`yyyy-MM-dd`).
  ///
  /// A todo with no due date counts as today's — it's something you meant to
  /// do, and hiding it until you set a date would defeat the point.
  static TodoSection sectionFor(Todo todo, String today) {
    if (todo.completed) return TodoSection.completed;
    if (todo.dueDate == null) return TodoSection.today;

    final due = DailyDateService.format(todo.dueDate!);
    final delta = DailyDateService.daysBetween(today, due);
    if (delta < 0) return TodoSection.overdue;
    if (delta == 0) return TodoSection.today;
    return TodoSection.upcoming;
  }
}
