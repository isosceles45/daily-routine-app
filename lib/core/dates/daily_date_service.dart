/// A "day" in Daily Ritual is the device's **local calendar date**.
///
/// The app never depends on being open at midnight: the current date is
/// compared against the stored one on cold start and again every time the app
/// returns to the foreground, so closing at 23:50 and reopening at 08:00 is
/// correctly recognised as a new day.
class DailyDateService {
  const DailyDateService();

  /// Today as `yyyy-MM-dd`.
  String today() => format(DateTime.now());

  static String format(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static final _pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static DateTime parse(String date) {
    if (!_pattern.hasMatch(date)) {
      throw FormatException('Expected yyyy-MM-dd, got "$date"', date);
    }

    final year = int.parse(date.substring(0, 4));
    final month = int.parse(date.substring(5, 7));
    final day = int.parse(date.substring(8, 10));

    final parsed = DateTime(year, month, day);

    // DateTime silently rolls overflow forward — DateTime(2026, 2, 31) becomes
    // 3 March. Round-tripping catches that, and catches a reversed date like
    // `26-08-2026` being read as year 26.
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      throw FormatException('Not a real calendar date: "$date"', date);
    }
    return parsed;
  }

  /// Whole days from [from] to [to].
  ///
  /// [parse] returns midnight-local values, but a DST boundary can still make
  /// the raw difference 23 or 25 hours — rounding absorbs that.
  static int daysBetween(String from, String to) {
    final hours = parse(to).difference(parse(from)).inHours;
    return (hours / 24).round();
  }

  /// True when [a] and [b] are consecutive calendar dates.
  static bool isConsecutive(String a, String b) => daysBetween(a, b) == 1;

  static String weekdayName(String date) => switch (parse(date).weekday) {
        DateTime.monday => 'Monday',
        DateTime.tuesday => 'Tuesday',
        DateTime.wednesday => 'Wednesday',
        DateTime.thursday => 'Thursday',
        DateTime.friday => 'Friday',
        DateTime.saturday => 'Saturday',
        _ => 'Sunday',
      };

  static String monthDay(String date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final dt = parse(date);
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
