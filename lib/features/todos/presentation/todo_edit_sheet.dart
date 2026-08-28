import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/database/database.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/todo.dart';
import '../providers/todo_providers.dart';

/// Edit or delete a todo. Opened by tapping the row; the checkbox stays a
/// separate target so completing something never costs a trip through a form.
Future<void> showTodoEditSheet(BuildContext context, Todo todo) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: RitualColors.bg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _TodoEditSheet(todo: todo),
  );
}

class _TodoEditSheet extends ConsumerStatefulWidget {
  const _TodoEditSheet({required this.todo});

  final Todo todo;

  @override
  ConsumerState<_TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends ConsumerState<_TodoEditSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.todo.title,
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.todo.description ?? '',
  );

  late TodoPriority _priority = TodoPriority.fromValue(widget.todo.priority);
  late DateTime? _dueDate = widget.todo.dueDate;
  late bool _remind = widget.todo.reminderAt != null;

  /// Reminders fire mid-morning on the due date. A specific time picker is
  /// more precision than a todo list needs, and every extra field is another
  /// reason not to bother setting one at all.
  static const _reminderHour = 9;

  DateTime? get _reminderAt {
    if (!_remind || _dueDate == null) return null;
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _reminderHour,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final reminder = _reminderAt;

    await ref
        .read(todoRepositoryProvider)
        .edit(
          widget.todo.id,
          title: title,
          description: _notes.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
          // An explicit clear has to be distinguishable from "leave it alone".
          clearDueDate: _dueDate == null,
          reminderAt: reminder,
          clearReminder: reminder == null,
        );

    // Scheduling follows the saved row, so the notification and the database
    // can never disagree about whether a reminder exists.
    await ref
        .read(notificationServiceProvider)
        .setTodoReminder(todoId: widget.todo.id, title: title, at: reminder);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RitualColors.surface,
        title: Text(
          'Delete this todo?',
          style: outfit(size: 16, weight: FontWeight.w800),
        ),
        content: Text(widget.todo.title, style: RitualText.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: outfit(size: 13, color: RitualColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: outfit(
                size: 13,
                weight: FontWeight.w800,
                color: RitualColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    // Cancel first: a reminder for a deleted todo is the worst kind of
    // notification.
    await ref
        .read(notificationServiceProvider)
        .cancelTodoReminder(widget.todo.id);
    await ref.read(todoRepositoryProvider).remove(widget.todo.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift the sheet above the keyboard rather than letting it cover the
      // fields being edited.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RitualColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Eyebrow('Edit todo'),
              const SizedBox(height: 12),
              _Field(controller: _title, hint: 'What needs doing?'),
              const SizedBox(height: 10),
              _Field(controller: _notes, hint: 'Notes (optional)', maxLines: 3),
              const SizedBox(height: 18),
              Eyebrow('Priority'),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final priority in TodoPriority.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _Choice(
                        label: priority.label,
                        selected: _priority == priority,
                        onTap: () => setState(() => _priority = priority),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Eyebrow('Due date'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Choice(
                    label: _dueDate == null
                        ? 'Pick a date'
                        : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    selected: _dueDate != null,
                    onTap: _pickDueDate,
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(width: 8),
                    _Choice(
                      label: 'Clear',
                      selected: false,
                      onTap: () => setState(() {
                        _dueDate = null;
                        // A reminder with no date to hang on cannot fire.
                        _remind = false;
                      }),
                    ),
                  ],
                ],
              ),
              if (_dueDate != null) ...[
                const SizedBox(height: 14),
                _Choice(
                  label: _remind
                      ? 'Reminder at 9:00 on'
                      : 'Remind me on the day',
                  selected: _remind,
                  onTap: () => setState(() => _remind = !_remind),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(label: 'Save', onPressed: _save),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      RitualShape.buttonRadius,
                    ),
                    child: InkWell(
                      onTap: _delete,
                      borderRadius: BorderRadius.circular(
                        RitualShape.buttonRadius,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: RitualColors.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            RitualShape.buttonRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: RitualColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(RitualShape.inputRadius),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: outfit(size: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: outfit(size: 14, color: RitualColors.textTertiary),
        filled: true,
        fillColor: RitualColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: border(RitualColors.borderStrong),
        enabledBorder: border(RitualColors.borderStrong),
        focusedBorder: border(RitualColors.accent),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? RitualColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(RitualShape.inputRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RitualShape.inputRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            border: selected
                ? null
                : Border.all(color: RitualColors.borderStrong, width: 1.5),
            borderRadius: BorderRadius.circular(RitualShape.inputRadius),
          ),
          child: Text(
            label,
            style: outfit(
              size: 12,
              weight: FontWeight.w700,
              color: selected
                  ? RitualColors.onAccent
                  : RitualColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
