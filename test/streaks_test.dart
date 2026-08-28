import 'package:daily_ritual/core/utils/streaks.dart';
import 'package:flutter_test/flutter_test.dart';

const today = '2026-08-26';

void main() {
  group('current', () {
    test('is zero with no history', () {
      expect(StreakCalculator.current({}, today), 0);
    });

    test('counts a run ending today', () {
      expect(
        StreakCalculator.current(
            {'2026-08-24', '2026-08-25', '2026-08-26'}, today),
        3,
      );
    });

    test('survives a today that has not happened yet', () {
      // 00:01 and you haven't played — the streak is intact, not broken.
      expect(
        StreakCalculator.current(
            {'2026-08-23', '2026-08-24', '2026-08-25'}, today),
        3,
      );
    });

    test('breaks once a whole day is missed', () {
      expect(
        StreakCalculator.current(
            {'2026-08-22', '2026-08-23', '2026-08-24'}, today),
        0,
      );
    });

    test('ignores days after a gap', () {
      expect(
        StreakCalculator.current(
            {'2026-08-01', '2026-08-02', '2026-08-25', '2026-08-26'}, today),
        2,
      );
    });

    test('a single day today counts as one', () {
      expect(StreakCalculator.current({today}, today), 1);
    });

    test('future dates do not extend the streak', () {
      expect(
        StreakCalculator.current({'2026-08-26', '2026-08-27'}, today),
        1,
      );
    });

    test('crosses month and year boundaries', () {
      expect(
        StreakCalculator.current(
            {'2026-07-31', '2026-08-01'}, '2026-08-01'),
        2,
      );
      expect(
        StreakCalculator.current(
            {'2026-12-31', '2027-01-01'}, '2027-01-01'),
        2,
      );
    });
  });

  group('longest', () {
    test('is zero with no history', () {
      expect(StreakCalculator.longest({}), 0);
    });

    test('finds the best run, not the most recent', () {
      expect(
        StreakCalculator.longest({
          '2026-08-01', '2026-08-02', '2026-08-03', '2026-08-04',
          '2026-08-20', '2026-08-21',
        }),
        4,
      );
    });

    test('a lone day is a run of one', () {
      expect(StreakCalculator.longest({'2026-08-26'}), 1);
    });

    test('is order-independent', () {
      expect(
        StreakCalculator.longest(
            {'2026-08-03', '2026-08-01', '2026-08-02'}),
        3,
      );
    });

    test('never falls below the current streak', () {
      const dates = {'2026-08-24', '2026-08-25', '2026-08-26'};
      expect(
        StreakCalculator.longest(dates),
        greaterThanOrEqualTo(StreakCalculator.current(dates, today)),
      );
    });
  });
}
