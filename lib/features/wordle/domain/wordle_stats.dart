import '../../../core/database/database.dart';
import '../../../core/utils/streaks.dart';

/// The Wordle statistics the History tab draws (§6).
class WordleStats {
  const WordleStats({
    required this.total,
    required this.solved,
    required this.currentStreak,
    required this.longestStreak,
    required this.distribution,
    required this.average,
    required this.best,
  });

  static const empty = WordleStats(
    total: 0,
    solved: 0,
    currentStreak: 0,
    longestStreak: 0,
    distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0},
    average: null,
    best: null,
  );

  /// Every imported result, including failures.
  final int total;

  final int solved;
  final int currentStreak;
  final int longestStreak;

  /// Guess count → how many puzzles were solved in that many guesses.
  final Map<int, int> distribution;

  /// Mean guesses across solved puzzles. Null until something is solved —
  /// failures have no score to average, and counting them as 6 or as 7 would
  /// both be inventions.
  final double? average;

  final int? best;

  /// Percentage of imported puzzles that were solved.
  double get winRate => total == 0 ? 0 : solved / total * 100;

  /// The tallest bar, used to scale the distribution chart.
  int get distributionPeak =>
      distribution.values.fold(0, (a, b) => a > b ? a : b);

  String get averageLabel =>
      average == null ? '—' : average!.toStringAsFixed(1);

  static WordleStats from(List<WordleResult> results, String today) {
    if (results.isEmpty) return empty;

    final distribution = {for (var i = 1; i <= 6; i++) i: 0};
    var solved = 0;
    var scoreTotal = 0;
    int? best;

    for (final result in results) {
      final score = result.score;
      if (result.completed && score != null && score >= 1 && score <= 6) {
        solved++;
        scoreTotal += score;
        distribution[score] = distribution[score]! + 1;
        if (best == null || score < best) best = score;
      }
    }

    // A streak is a run of *solved* puzzles, matching how the NYT counts it —
    // a failed board ends it even though the day was still played.
    final solvedDates = results
        .where((r) => r.completed)
        .map((r) => r.date)
        .toSet();

    return WordleStats(
      total: results.length,
      solved: solved,
      currentStreak: StreakCalculator.current(solvedDates, today),
      longestStreak: StreakCalculator.longest(solvedDates),
      distribution: distribution,
      average: solved == 0 ? null : scoreTotal / solved,
      best: best,
    );
  }
}
