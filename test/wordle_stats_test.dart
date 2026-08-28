import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/features/wordle/domain/wordle_stats.dart';
import 'package:flutter_test/flutter_test.dart';

const today = '2026-08-26';

WordleResult result(String date, int? score) => WordleResult(
      date: date,
      wordleNumber: 1000,
      score: score,
      completed: score != null,
      hardMode: false,
      importedAt: DateTime(2026, 8, 26),
    );

void main() {
  test('empty history reports nothing rather than zero', () {
    const stats = WordleStats.empty;
    expect(stats.total, 0);
    expect(stats.average, isNull);
    expect(stats.averageLabel, '—');
    expect(stats.best, isNull);
  });

  test('averages only the solved puzzles', () {
    final stats = WordleStats.from([
      result('2026-08-26', 3),
      result('2026-08-25', 5),
      // A failure has no score; counting it as 6 or 7 would both be inventions.
      result('2026-08-24', null),
    ], today);

    expect(stats.total, 3);
    expect(stats.solved, 2);
    expect(stats.average, closeTo(4.0, 1e-9));
    expect(stats.best, 3);
  });

  test('builds the 1–6 distribution', () {
    final stats = WordleStats.from([
      result('2026-08-26', 4),
      result('2026-08-25', 4),
      result('2026-08-24', 2),
      result('2026-08-23', null),
    ], today);

    expect(stats.distribution[4], 2);
    expect(stats.distribution[2], 1);
    expect(stats.distribution[1], 0);
    expect(stats.distributionPeak, 2);
  });

  test('a failure breaks the streak but still counts as a game', () {
    final stats = WordleStats.from([
      result('2026-08-26', 3),
      result('2026-08-25', null),
      result('2026-08-24', 3),
      result('2026-08-23', 3),
    ], today);

    // NYT semantics: the streak counts solved puzzles, so the miss on the 25th
    // ends the earlier run.
    expect(stats.currentStreak, 1);
    expect(stats.longestStreak, 2);
    expect(stats.total, 4);
    expect(stats.solved, 3);
  });

  test('an unbroken run streaks', () {
    final stats = WordleStats.from([
      result('2026-08-26', 3),
      result('2026-08-25', 4),
      result('2026-08-24', 2),
    ], today);

    expect(stats.currentStreak, 3);
    expect(stats.longestStreak, 3);
  });

  test('not having played today does not break the streak', () {
    final stats = WordleStats.from([
      result('2026-08-25', 4),
      result('2026-08-24', 2),
    ], today);

    expect(stats.currentStreak, 2);
  });

  test('win rate reflects failures', () {
    final stats = WordleStats.from([
      result('2026-08-26', 3),
      result('2026-08-25', null),
    ], today);

    expect(stats.winRate, closeTo(50.0, 1e-9));
  });

  test('ignores an out-of-range score rather than corrupting the chart', () {
    // Defensive: a bad row must not create a distribution bucket of its own.
    final stats = WordleStats.from([result('2026-08-26', 9)], today);
    expect(stats.solved, 0);
    expect(stats.distribution.keys, [1, 2, 3, 4, 5, 6]);
  });
}
