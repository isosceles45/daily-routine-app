import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/dates/daily_date_service.dart';
import '../../../core/database/database.dart' show Event;
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/countdown.dart';
import '../providers/event_providers.dart';

/// The countdown strip at the top of the Todos tab.
///
/// Horizontal rather than a list: countdowns are glanceable by nature, and a
/// vertical list of them would push the actual todos off the screen.
class CountdownSection extends ConsumerWidget {
  const CountdownSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdowns = ref.watch(countdownsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Eyebrow(
                  'Counting down',
                  color: RitualColors.accent,
                  letterSpacing: 0.1,
                ),
              ),
              _AddButton(onTap: () => showEventSheet(context, ref)),
            ],
          ),
        ),
        if (countdowns.isEmpty)
          const _EmptyCountdown()
        else
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: countdowns.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _CountdownCard(countdowns[i]),
            ),
          ),
      ],
    );
  }
}

class _CountdownCard extends ConsumerWidget {
  const _CountdownCard(this.countdown);

  final Countdown countdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A countdown that has arrived is the loud one; one that has passed
    // steps back rather than being deleted out from under the user.
    final accent = countdown.isPast
        ? RitualColors.textTertiary
        : countdown.days <= 7
        ? RitualColors.accent
        : context.features.place;

    return SizedBox(
      width: 172,
      child: RitualCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        onTap: () => showEventSheet(context, ref, existing: countdown),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                RitualIcon(countdown.icon, size: 16, color: accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    countdown.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: outfit(
                      size: 12.5,
                      weight: FontWeight.w700,
                      color: RitualColors.text,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countdown.headline,
                  style: outfit(
                    size: 21,
                    weight: FontWeight.w800,
                    color: accent,
                    letterSpacing: -0.01,
                  ),
                ),
                Text(
                  countdown.subtitle,
                  style: outfit(size: 11, color: RitualColors.textTertiary),
                ),
              ],
            ),
            Text(
              '${countdown.weekday.substring(0, 3)} · '
              '${countdown.calendarLabel}',
              style: outfit(size: 10.5, color: RitualColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCountdown extends ConsumerWidget {
  const _EmptyCountdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: RitualCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: () => showEventSheet(context, ref),
        child: Row(
          children: [
            const RitualIcon(
              RitualIcons.calendar,
              size: 18,
              color: RitualColors.accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add a trip, an exam, a birthday — anything worth counting '
                'the days to.',
                style: outfit(size: 12.5, color: RitualColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.add, size: 18, color: RitualColors.accent),
        ),
      ),
    );
  }
}

/// Create or edit a countdown.
Future<void> showEventSheet(
  BuildContext context,
  WidgetRef ref, {
  Countdown? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: RitualColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EventSheet(existing: existing),
  );
}

class _EventSheet extends ConsumerStatefulWidget {
  const _EventSheet({this.existing});

  final Countdown? existing;

  @override
  ConsumerState<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends ConsumerState<_EventSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late String _date = widget.existing?.date ?? ref.read(currentDateProvider);
  late RitualIcons _icon = widget.existing?.icon ?? RitualIcons.calendar;

  static const _iconChoices = [
    RitualIcons.calendar,
    RitualIcons.plane,
    RitualIcons.mountain,
    RitualIcons.beach,
    RitualIcons.train,
    RitualIcons.cake,
    RitualIcons.graduation,
    RitualIcons.note,
    RitualIcons.party,
    RitualIcons.ring,
  ];

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = DailyDateService.parse(_date);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      // Countdowns run both ways — you can add something that already
      // happened and watch the "days ago" climb.
      firstDate: DateTime(current.year - 5),
      lastDate: DateTime(current.year + 20),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: RitualColors.accent,
            onPrimary: RitualColors.onAccent,
            surface: RitualColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _date = DailyDateService.format(picked));
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(eventRepositoryProvider);
    final existing = widget.existing;

    if (existing == null) {
      await repo.add(
        title: title,
        date: _date,
        note: _note.text,
        emoji: _icon.name,
      );
    } else {
      await repo.update(
        existing.id,
        title: title,
        date: _date,
        note: _note.text,
        emoji: _icon.name,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    await ref.read(eventRepositoryProvider).remove(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final preview = Countdown(
      event: Event(
        id: 'preview',
        title: _title.text,
        date: _date,
        pinned: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      today: ref.watch(currentDateProvider),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(
            widget.existing == null ? 'New countdown' : 'Edit countdown',
            color: RitualColors.accent,
            letterSpacing: 0.1,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _title,
            autofocus: widget.existing == null,
            style: RitualText.bodySmall,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Uttarakhand trip',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (final choice in _iconChoices)
                GestureDetector(
                  onTap: () => setState(() => _icon = choice),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _icon == choice
                          ? RitualColors.accentSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _icon == choice
                            ? RitualColors.accent
                            : Colors.transparent,
                      ),
                    ),
                    child: RitualIcon(
                      choice,
                      size: 18,
                      color: _icon == choice
                          ? RitualColors.accentSoftText
                          : RitualColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          RitualCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: _pickDate,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: RitualColors.textTertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${preview.weekday}, ${preview.calendarLabel}',
                    style: RitualText.bodySmall,
                  ),
                ),
                Text(
                  preview.headline,
                  style: outfit(
                    size: 13,
                    weight: FontWeight.w800,
                    color: RitualColors.accent,
                  ),
                ),
              ],
            ),
          ),
          if (preview.weeksHint != null) ...[
            const SizedBox(height: 6),
            Text(
              preview.weeksHint!,
              style: outfit(size: 11, color: RitualColors.textTertiary),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            style: RitualText.bodySmall,
            decoration: const InputDecoration(
              hintText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.existing != null) ...[
                TextButton(
                  onPressed: _delete,
                  child: Text(
                    'Delete',
                    style: outfit(size: 13, color: RitualColors.error),
                  ),
                ),
                const Spacer(),
              ],
              Expanded(
                flex: widget.existing == null ? 1 : 0,
                child: PrimaryButton(
                  label: widget.existing == null ? 'Add' : 'Save',
                  onPressed: _title.text.trim().isEmpty ? null : _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
