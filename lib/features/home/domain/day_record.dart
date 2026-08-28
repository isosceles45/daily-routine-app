import 'daily_completion.dart';

/// What was completed on one past day, for the History timeline.
class DayRecord {
  const DayRecord({required this.date, required this.completed});

  final String date;
  final Set<DailyActivity> completed;

  bool didComplete(DailyActivity activity) => completed.contains(activity);

  /// A day counts towards the overall streak if *anything* was done (§15).
  /// Optional content must never be able to break it.
  bool get counts => completed.isNotEmpty;
}

/// Every streak the app tracks, kept independent so a missed Wordle doesn't
/// wipe out an otherwise unbroken run (§15).
class Streaks {
  const Streaks({
    required this.overallCurrent,
    required this.overallLongest,
    required this.triviaCurrent,
    required this.catQuantCurrent,
    required this.wordleCurrent,
  });

  static const empty = Streaks(
    overallCurrent: 0,
    overallLongest: 0,
    triviaCurrent: 0,
    catQuantCurrent: 0,
    wordleCurrent: 0,
  );

  final int overallCurrent;
  final int overallLongest;
  final int triviaCurrent;
  final int catQuantCurrent;
  final int wordleCurrent;
}
