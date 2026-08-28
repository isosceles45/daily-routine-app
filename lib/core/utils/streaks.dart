import '../dates/daily_date_service.dart';

/// Streak arithmetic over a set of `yyyy-MM-dd` dates (§15).
///
/// Deliberately generic: the overall streak, the Wordle streak and every
/// per-feature streak are the same calculation over a different set of days.
abstract final class StreakCalculator {
  /// Length of the streak ending today.
  ///
  /// If today isn't in [dates] the streak is measured to *yesterday* instead:
  /// the day isn't over, and showing a streak collapse at 00:01 because you
  /// haven't played yet would be punishing the user for the clock (§15).
  /// It only breaks once a full day has been missed.
  static int current(Set<String> dates, String today) {
    if (dates.isEmpty) return 0;

    var cursor = today;
    if (!dates.contains(cursor)) {
      cursor = _shift(today, -1);
      if (!dates.contains(cursor)) return 0;
    }

    var length = 0;
    while (dates.contains(cursor)) {
      length++;
      cursor = _shift(cursor, -1);
    }
    return length;
  }

  /// The longest run of consecutive days ever recorded.
  static int longest(Set<String> dates) {
    if (dates.isEmpty) return 0;

    final sorted = dates.toList()..sort();
    var best = 1;
    var run = 1;

    for (var i = 1; i < sorted.length; i++) {
      if (DailyDateService.isConsecutive(sorted[i - 1], sorted[i])) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }
    return best;
  }

  static String _shift(String date, int days) => DailyDateService.format(
    DailyDateService.parse(date).add(Duration(days: days)),
  );
}
