import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/database/database.dart';
import '../domain/todo.dart';
import '../providers/todo_providers.dart';
import 'todo_edit_sheet.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(todoRepositoryProvider).add(title: text);
    // Keep focus so several todos can be added in a row without re-tapping.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(sectionedTodosProvider);

    return SafeArea(
      bottom: false,
      child: RiseIn(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Todos', style: RitualText.tabTitle),
              ),
            ),
            Expanded(
              child: sections.isEmpty
                  ? _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        for (final entry in sections.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Eyebrow(
                              _sectionLabel(entry.key),
                              color: _sectionColor(entry.key),
                              letterSpacing: 0.1,
                            ),
                          ),
                          for (final todo in entry.value) _TodoRow(todo: todo),
                        ],
                      ],
                    ),
            ),
            _Composer(controller: _controller, focus: _focus, onAdd: _add),
          ],
        ),
      ),
    );
  }

  static String _sectionLabel(TodoSection section) => switch (section) {
    TodoSection.today => 'Today',
    TodoSection.upcoming => 'Upcoming',
    TodoSection.overdue => 'Overdue',
    TodoSection.completed => 'Completed',
  };

  static Color _sectionColor(TodoSection section) => switch (section) {
    TodoSection.today => RitualColors.text,
    TodoSection.overdue => RitualColors.accent,
    _ => RitualColors.textTertiary,
  };
}

class _TodoRow extends ConsumerWidget {
  const _TodoRow({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(todoRepositoryProvider);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: RitualColors.error.withValues(alpha: 0.18),
        child: const Icon(
          Icons.delete_outline,
          color: RitualColors.error,
          size: 20,
        ),
      ),
      onDismissed: (_) => repository.remove(todo.id),
      child: InkWell(
        // Tapping the row edits; the checkbox is its own target so ticking
        // something off never routes through a form.
        onTap: () => showTodoEditSheet(context, todo),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: RitualColors.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => repository.setCompleted(todo.id, !todo.completed),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  // Widen the tap target well past the 18px box.
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 3,
                  ),
                  child: RitualCheckbox(checked: todo.completed),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: outfit(
                        size: 13,
                        color: todo.completed
                            ? RitualColors.textTertiary
                            : RitualColors.text,
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (todo.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        todo.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: outfit(
                          size: 11,
                          color: RitualColors.textTertiary,
                        ),
                      ),
                    ],
                    if (todo.dueDate != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Due ${todo.dueDate!.day}/${todo.dueDate!.month}',
                        style: outfit(
                          size: 11,
                          color: RitualColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (todo.priority == TodoPriority.high.value && !todo.completed)
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 2),
                  child: Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: RitualColors.accent,
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(left: 4, top: 2),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: RitualColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focus,
                onSubmitted: (_) => onAdd(),
                textInputAction: TextInputAction.done,
                style: outfit(size: 13),
                decoration: InputDecoration(
                  hintText: 'Add a todo…',
                  hintStyle: outfit(size: 13, color: RitualColors.textTertiary),
                  filled: true,
                  fillColor: RitualColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      RitualShape.inputRadius,
                    ),
                    borderSide: const BorderSide(
                      color: RitualColors.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      RitualShape.inputRadius,
                    ),
                    borderSide: const BorderSide(
                      color: RitualColors.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      RitualShape.inputRadius,
                    ),
                    borderSide: const BorderSide(
                      color: RitualColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: RitualColors.accent,
              borderRadius: BorderRadius.circular(RitualShape.inputRadius),
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(RitualShape.inputRadius),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: RitualColors.onAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nothing here yet.',
              style: outfit(size: 16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Add the first thing you want to get done today.',
              textAlign: TextAlign.center,
              style: RitualText.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
