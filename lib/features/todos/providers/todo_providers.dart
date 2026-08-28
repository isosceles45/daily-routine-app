import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../data/todo_repository.dart';
import '../domain/todo.dart';

final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => TodoRepository(ref.watch(databaseProvider)),
);

final todosProvider = StreamProvider<List<Todo>>(
  (ref) => ref.watch(todoRepositoryProvider).watchAll(),
);

/// Todos bucketed into the canvas's four sections, in display order.
/// Empty sections are dropped so the list never shows a bare heading.
final sectionedTodosProvider = Provider<Map<TodoSection, List<Todo>>>((ref) {
  final todos = ref.watch(todosProvider).value ?? const <Todo>[];
  final today = ref.watch(currentDateProvider);

  final grouped = <TodoSection, List<Todo>>{};
  for (final section in TodoSection.values) {
    final items = todos
        .where((t) => TodoRepository.sectionFor(t, today) == section)
        .toList(growable: false);
    if (items.isNotEmpty) grouped[section] = items;
  }
  return grouped;
});

/// The handful shown inline on the Today dashboard.
final todayTodosProvider = Provider<List<Todo>>((ref) {
  final sections = ref.watch(sectionedTodosProvider);
  return sections[TodoSection.today] ?? const [];
});
