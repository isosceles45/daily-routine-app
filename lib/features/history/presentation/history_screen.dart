import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/dates/daily_date_service.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/domain/daily_completion.dart';
import '../../home/domain/day_record.dart';
import '../../home/providers/history_providers.dart';
import '../../wordle/presentation/wordle_distribution.dart';
import '../../wordle/providers/wordle_providers.dart';

enum _HistoryView { wordle, timeline }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _HistoryView _view = _HistoryView.wordle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RiseIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text('History', style: RitualText.tabTitle),
            const SizedBox(height: 14),
            _Segmented(
              value: _view,
              onChanged: (v) => setState(() => _view = v),
            ),
            const SizedBox(height: 20),
            if (_view == _HistoryView.wordle)
              const _WordleHistory()
            else
              const _Timeline(),
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.value, required this.onChanged});

  final _HistoryView value;
  final ValueChanged<_HistoryView> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, _HistoryView view) {
      final active = value == view;
      return InkWell(
        onTap: () => onChanged(view),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: active ? RitualColors.accent : Colors.transparent,
          child: Text(
            label.toUpperCase(),
            style: outfit(
              size: 12,
              weight: FontWeight.w800,
              color: active
                  ? RitualColors.onAccent
                  : RitualColors.textSecondary,
              letterSpacing: 0.04,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: RitualColors.borderStrong, width: 1.5),
          borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            segment('Wordle', _HistoryView.wordle),
            segment('Timeline', _HistoryView.timeline),
          ],
        ),
      ),
    );
  }
}

class _WordleHistory extends ConsumerWidget {
  const _WordleHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wordleStatsProvider);

    if (stats.total == 0) {
      return const _Empty(
        title: 'No Wordle results yet.',
        body:
            'Play today’s Wordle, tap Share, and paste it back here. '
            'Your streak and distribution build from there.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatBlock(
              value: '${stats.currentStreak}',
              label: 'Streak',
              size: 28,
            ),
            StatBlock(
              value: '${stats.longestStreak}',
              label: 'Longest',
              size: 28,
            ),
            StatBlock(value: stats.averageLabel, label: 'Average', size: 28),
            StatBlock(value: '${stats.total}', label: 'Games', size: 28),
          ],
        ),
        const SizedBox(height: 18),
        const RitualDivider(),
        const SizedBox(height: 18),
        WordleDistribution(stats: stats),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              'Solved ${stats.solved} of ${stats.total}',
              style: RitualText.bodySmall,
            ),
            const Spacer(),
            if (stats.best != null)
              Text('Best ${stats.best}/6', style: RitualText.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(dayRecordsProvider);
    final streaks = ref.watch(streaksProvider);

    if (records.isEmpty) {
      return const _Empty(
        title: 'Nothing recorded yet.',
        body:
            'Answer today’s trivia or CAT question and it will show up '
            'here.',
      );
    }

    // Only activities that can actually be completed today are worth a column.
    const tracked = [
      DailyActivity.wordle,
      DailyActivity.catQuant,
      DailyActivity.trivia,
      DailyActivity.fun,
      DailyActivity.pokemon,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            StatBlock(
              value: '${streaks.overallCurrent}',
              label: 'Day streak',
              size: 28,
            ),
            const SizedBox(width: 28),
            StatBlock(
              value: '${streaks.overallLongest}',
              label: 'Longest',
              size: 28,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const RitualDivider(),
        const SizedBox(height: 16),
        // Per-feature streaks are tracked separately (§15) so that missing one
        // activity never wipes out an otherwise unbroken run in another.
        Eyebrow('Streaks by activity'),
        const SizedBox(height: 12),
        Row(
          children: [
            StatBlock(value: '${streaks.wordleCurrent}', label: 'Wordle'),
            const SizedBox(width: 24),
            StatBlock(value: '${streaks.catQuantCurrent}', label: 'CAT'),
            const SizedBox(width: 24),
            StatBlock(value: '${streaks.triviaCurrent}', label: 'Trivia'),
          ],
        ),
        const SizedBox(height: 20),
        const RitualDivider(),
        for (final record in records.take(30))
          _TimelineRow(record: record, tracked: tracked),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.record, required this.tracked});

  final DayRecord record;
  final List<DailyActivity> tracked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RitualColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(
            DailyDateService.monthDay(record.date),
            letterSpacing: 0.08,
            size: 12,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final activity in tracked)
                _ActivityPip(
                  label: activity.label,
                  done: record.didComplete(activity),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityPip extends StatelessWidget {
  const _ActivityPip({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          done ? Icons.check : Icons.close,
          size: 13,
          color: done ? RitualColors.accent : RitualColors.textTertiary,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: outfit(
            size: 12,
            color: done
                ? RitualColors.textSecondary
                : RitualColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: outfit(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body, style: RitualText.bodySmall),
        ],
      ),
    );
  }
}
