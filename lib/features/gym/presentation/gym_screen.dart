import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/workout.dart';
import '../providers/gym_providers.dart';

/// The gym tab content: today's session, then the split that produced it.
class GymScreen extends ConsumerStatefulWidget {
  const GymScreen({super.key});

  @override
  ConsumerState<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends ConsumerState<GymScreen> {
  @override
  void initState() {
    super.initState();
    // Turn the in-memory default split into real rows the first time the
    // screen is opened, so editing one day does not invent the other six.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(gymRepositoryProvider).materialiseDefaults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(todayFocusProvider);

    // DetailScaffold already scrolls its child, so this is a Column: a
    // ListView inside a SingleChildScrollView gets unbounded height and
    // collapses to nothing.
    return DetailScaffold(
      title: 'Gym',
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TodayHeader(focus: focus),
          const SizedBox(height: RitualShape.stackGap),
          if (focus.isRest) const _RestCard() else const _SessionCard(),
          const SizedBox(height: 24),
          const RitualDivider(),
          const SizedBox(height: 20),
          const _SplitEditor(),
        ],
      ),
    );
  }
}

class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({required this.focus});

  final MuscleFocus focus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(todayDoneProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RitualIcon(focus.icon, size: 28, color: RitualColors.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('Today', color: RitualColors.accent, letterSpacing: 0.12),
              const SizedBox(height: 2),
              Text(focus.label, style: RitualText.stat(24)),
              if (done.isNotEmpty)
                Text(
                  '${done.length} logged',
                  style: outfit(size: 12, color: RitualColors.success),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RestCard extends StatelessWidget {
  const _RestCard();

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Row(
        children: [
          const RitualIcon(
            RitualIcons.rest,
            size: 22,
            color: RitualColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Rest day. Recovery is part of the programme — change it below '
              'if you want to train anyway.',
              style: RitualText.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(todaySessionProvider);
    final done = ref.watch(todayDoneProvider);
    final focus = ref.watch(todayFocusProvider);
    final date = ref.watch(currentDateProvider);

    return session.when(
      loading: () => LoadingCard(
        title: 'Suggested exercises',
        accent: RitualColors.accent,
      ),
      error: (_, _) => const _OfflineSession(),
      data: (exercises) {
        if (exercises.isEmpty) return const _OfflineSession();

        return RitualCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Eyebrow(
                      'Suggested — wger',
                      color: RitualColors.accent,
                      letterSpacing: 0.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await ref
                          .read(gymRepositoryProvider)
                          .reshuffle(date, focus);
                      ref.invalidate(todaySessionProvider);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: RitualColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final exercise in exercises)
                _ExerciseRow(
                  exercise: exercise,
                  checked: done.contains(exercise.name),
                  onTap: () => ref
                      .read(gymRepositoryProvider)
                      .toggleExercise(
                        date: date,
                        focus: focus,
                        exercise: exercise.name,
                      ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Shown when wger could not be reached.
///
/// Deliberately not an error card: the split is local, so you can still train
/// and still log it — only the suggestions are missing.
class _OfflineSession extends ConsumerWidget {
  const _OfflineSession();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(todayFocusProvider);
    final date = ref.watch(currentDateProvider);
    final done = ref.watch(todayDoneProvider);

    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(
            'No suggestions right now',
            color: RitualColors.textTertiary,
            letterSpacing: 0.1,
          ),
          const SizedBox(height: 8),
          Text(
            "Couldn't reach wger, so there is no exercise list today. The "
            'session is still yours to log.',
            style: RitualText.bodySmall,
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: done.isEmpty ? 'Log ${focus.label} anyway' : 'Logged',
            onPressed: done.isEmpty
                ? () => ref
                      .read(gymRepositoryProvider)
                      .toggleExercise(
                        date: date,
                        focus: focus,
                        exercise: '${focus.label} session',
                      )
                : null,
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.checked,
    required this.onTap,
  });

  final Exercise exercise;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RitualCheckbox(checked: checked),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                exercise.name,
                style: outfit(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: checked
                      ? RitualColors.textTertiary
                      : RitualColors.text,
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The weekly split, edited in place.
class _SplitEditor extends ConsumerWidget {
  const _SplitEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final split = ref.watch(weeklySplitProvider).value ?? WeeklySplit.defaults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Your split', letterSpacing: 0.12),
        const SizedBox(height: 4),
        Text(
          '${split.trainingDays} training days a week',
          style: outfit(size: 12, color: RitualColors.textTertiary),
        ),
        const SizedBox(height: 12),
        for (final weekday in WeeklySplit.weekdayOrder)
          _SplitRow(weekday: weekday, focus: split.focusFor(weekday)),
      ],
    );
  }
}

class _SplitRow extends ConsumerWidget {
  const _SplitRow({required this.weekday, required this.focus});

  final int weekday;
  final MuscleFocus focus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              WeeklySplit.shortName(weekday),
              style: outfit(
                size: 12.5,
                weight: FontWeight.w700,
                color: RitualColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final option in MuscleFocus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FocusChip(
                        focus: option,
                        selected: option == focus,
                        onTap: () => ref
                            .read(gymRepositoryProvider)
                            .setFocus(weekday, option),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.focus,
    required this.selected,
    required this.onTap,
  });

  final MuscleFocus focus;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? RitualColors.accent.withValues(alpha: 0.18)
          : RitualColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? RitualColors.accent : RitualColors.border,
            ),
          ),
          child: Text(
            focus.label,
            style: outfit(
              size: 11.5,
              weight: FontWeight.w700,
              color: selected
                  ? RitualColors.accent
                  : RitualColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
