import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/features/todos/data/todo_repository.dart';
import 'package:daily_ritual/features/todos/domain/todo.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TodoRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = TodoRepository(db);
  });

  tearDown(() async => db.close());

  test('adds a todo and trims its title', () async {
    final todo = await repository.add(title: '  Buy coffee  ');
    expect(todo.title, 'Buy coffee');
    expect(todo.completed, isFalse);
    expect(todo.priority, TodoPriority.normal.value);

    final all = await db.select(db.todos).get();
    expect(all, hasLength(1));
  });

  test('edits fields without disturbing the others', () async {
    final todo = await repository.add(title: 'Original', description: 'Note');

    await repository.edit(todo.id, title: 'Renamed');

    final updated = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(todo.id))).getSingle();
    expect(updated.title, 'Renamed');
    expect(
      updated.description,
      'Note',
      reason: 'omitting an argument must leave the column alone',
    );
    expect(
      updated.updatedAt.isAfter(
        todo.createdAt.subtract(const Duration(seconds: 1)),
      ),
      isTrue,
    );
  });

  test('clearing notes stores null, not an empty string', () async {
    final todo = await repository.add(title: 'X', description: 'Some note');
    await repository.edit(todo.id, description: '   ');

    final updated = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(todo.id))).getSingle();
    expect(updated.description, isNull);
  });

  test('sets and clears a due date', () async {
    final todo = await repository.add(title: 'X');
    final due = DateTime(2026, 9, 1);

    await repository.edit(todo.id, dueDate: due);
    var updated = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(todo.id))).getSingle();
    expect(updated.dueDate, due);

    await repository.edit(todo.id, clearDueDate: true);
    updated = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(todo.id))).getSingle();
    expect(
      updated.dueDate,
      isNull,
      reason: 'clearing must be distinguishable from not passing a value',
    );
  });

  test('completing stamps completedAt, uncompleting clears it', () async {
    final todo = await repository.add(title: 'X');

    await repository.setCompleted(todo.id, true);
    var updated = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(todo.id))).getSingle();
    expect(updated.completed, isTrue);
    expect(updated.completedAt, isNotNull);

    await repository.setCompleted(todo.id, false);
    updated = await (db.select(
      db.todos,
    )..where((t) => t.id.equals(todo.id))).getSingle();
    expect(updated.completed, isFalse);
    expect(updated.completedAt, isNull);
  });

  test('removes a todo', () async {
    final todo = await repository.add(title: 'Delete me');
    await repository.remove(todo.id);
    expect(await db.select(db.todos).get(), isEmpty);
  });

  test('removing one leaves the others alone', () async {
    final keep = await repository.add(title: 'Keep');
    final drop = await repository.add(title: 'Drop');

    await repository.remove(drop.id);

    final all = await db.select(db.todos).get();
    expect(all, hasLength(1));
    expect(all.single.id, keep.id);
  });

  test('orders unfinished first, then by priority', () async {
    await repository.add(title: 'Low', priority: TodoPriority.low);
    await repository.add(title: 'High', priority: TodoPriority.high);
    final done = await repository.add(title: 'Done');
    await repository.setCompleted(done.id, true);

    final ordered = await repository.watchAll().first;
    expect(ordered.map((t) => t.title), ['High', 'Low', 'Done']);
  });

  test('the stream emits on every change', () async {
    final emissions = <int>[];
    final sub = repository.watchAll().listen(
      (rows) => emissions.add(rows.length),
    );

    await repository.add(title: 'One');
    await repository.add(title: 'Two');
    await Future<void>.delayed(const Duration(milliseconds: 60));
    await sub.cancel();

    expect(emissions.last, 2);
  });
}
