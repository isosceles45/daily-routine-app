import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/features/todos/data/todo_repository.dart';
import 'package:daily_ritual/features/todos/domain/todo.dart';
import 'package:flutter_test/flutter_test.dart';

const today = '2026-08-26';

Todo todo({
  bool completed = false,
  DateTime? dueDate,
  TodoPriority priority = TodoPriority.normal,
}) {
  final now = DateTime(2026, 8, 26, 9);
  return Todo(
    id: 'id',
    title: 'Something',
    completed: completed,
    priority: priority.value,
    createdAt: now,
    updatedAt: now,
    dueDate: dueDate,
  );
}

void main() {
  group('sectionFor', () {
    test('a todo with no due date belongs to today', () {
      // Hiding undated todos until a date is set would defeat the point of a
      // quick-add field.
      expect(TodoRepository.sectionFor(todo(), today), TodoSection.today);
    });

    test('due today is today', () {
      expect(
        TodoRepository.sectionFor(
          todo(dueDate: DateTime(2026, 8, 26, 23, 59)),
          today,
        ),
        TodoSection.today,
      );
    });

    test('due yesterday is overdue', () {
      expect(
        TodoRepository.sectionFor(todo(dueDate: DateTime(2026, 8, 25)), today),
        TodoSection.overdue,
      );
    });

    test('due tomorrow is upcoming', () {
      expect(
        TodoRepository.sectionFor(todo(dueDate: DateTime(2026, 8, 27)), today),
        TodoSection.upcoming,
      );
    });

    test('completed wins over any due date', () {
      // An overdue todo you have finished is done, not a reproach.
      expect(
        TodoRepository.sectionFor(
          todo(completed: true, dueDate: DateTime(2026, 1, 1)),
          today,
        ),
        TodoSection.completed,
      );
    });

    test('time of day never moves a todo between sections', () {
      for (final hour in [0, 6, 12, 23]) {
        expect(
          TodoRepository.sectionFor(
            todo(dueDate: DateTime(2026, 8, 26, hour)),
            today,
          ),
          TodoSection.today,
        );
      }
    });
  });

  group('newId', () {
    test('does not collide across rapid successive calls', () {
      final ids = {for (var i = 0; i < 500; i++) TodoRepository.newId()};
      expect(ids, hasLength(500));
    });
  });

  group('TodoPriority', () {
    test('maps stored ints back to values', () {
      expect(TodoPriority.fromValue(0), TodoPriority.low);
      expect(TodoPriority.fromValue(2), TodoPriority.high);
    });

    test('falls back to normal for an unknown value', () {
      expect(TodoPriority.fromValue(99), TodoPriority.normal);
    });
  });
}
