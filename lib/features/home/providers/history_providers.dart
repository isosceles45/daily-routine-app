import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/streaks.dart';
import '../../cat_quant/providers/cat_providers.dart';
import '../../gym/providers/gym_providers.dart';
import '../../trivia/providers/trivia_providers.dart';
import '../../wordle/providers/wordle_providers.dart';
import '../domain/daily_completion.dart';
import '../domain/day_record.dart';

/// The `seen:<date>:<activity>` markers for every day, not just today.
final seenMarkersProvider = StreamProvider<List<AppSetting>>(
  (ref) => ref.watch(databaseProvider).watchSeenMarkers(),
);

/// One record per day the user did anything, newest first.
///
/// Assembled from the activity tables rather than a dedicated history table,
/// so there is exactly one source of truth for "did this happen".
final dayRecordsProvider = Provider<List<DayRecord>>((ref) {
  final byDate = <String, Set<DailyActivity>>{};

  void mark(String date, DailyActivity activity) {
    byDate.putIfAbsent(date, () => <DailyActivity>{}).add(activity);
  }

  for (final result in ref.watch(wordleResultsProvider).value ?? const []) {
    mark(result.date, DailyActivity.wordle);
  }

  for (final result in ref.watch(triviaAllResultsProvider).value ?? const []) {
    if (result.answered) mark(result.date, DailyActivity.trivia);
  }

  for (final result in ref.watch(catAllResultsProvider).value ?? const []) {
    if (result.answered) mark(result.date, DailyActivity.catQuant);
  }

  for (final log in ref.watch(allWorkoutLogsProvider).value ?? const []) {
    if (log.completed) mark(log.date, DailyActivity.gym);
  }

  for (final marker in ref.watch(seenMarkersProvider).value ?? const []) {
    // Keys look like `seen:2026-08-26:pokemon`.
    final parts = marker.key.split(':');
    if (parts.length != 3) continue;

    final activity = DailyActivity.values
        .where((a) => a.name == parts[2])
        .firstOrNull;
    if (activity != null) mark(parts[1], activity);
  }

  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates) DayRecord(date: date, completed: byDate[date]!),
  ];
});

final streaksProvider = Provider<Streaks>((ref) {
  final today = ref.watch(currentDateProvider);
  final records = ref.watch(dayRecordsProvider);

  Set<String> datesWith(DailyActivity activity) =>
      records.where((r) => r.didComplete(activity)).map((r) => r.date).toSet();

  final counting = records.where((r) => r.counts).map((r) => r.date).toSet();

  return Streaks(
    overallCurrent: StreakCalculator.current(counting, today),
    overallLongest: StreakCalculator.longest(counting),
    triviaCurrent: StreakCalculator.current(
      datesWith(DailyActivity.trivia),
      today,
    ),
    catQuantCurrent: StreakCalculator.current(
      datesWith(DailyActivity.catQuant),
      today,
    ),
    // The Wordle streak counts solved puzzles, so it comes from the stats,
    // which know the difference between playing and winning.
    wordleCurrent: ref.watch(wordleStatsProvider).currentStreak,
  );
});
