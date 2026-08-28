/// The seven activities the Today screen tracks (§14).
///
/// The canvas shows `4 / 7` over seven progress cells, so the set is fixed —
/// but features arrive across phases, and a slot that doesn't exist yet must
/// not be counted as "not done". [DailyCompletion] therefore scores only the
/// activities that are actually available.
enum DailyActivity {
  wordle('Wordle'),
  catQuant('CAT Quant'),
  trivia('Trivia'),
  fun('Daily Fun'),
  pokemon('Pokémon'),
  challenge('Challenge'),
  surprise('Surprise');

  const DailyActivity(this.label);

  final String label;
}

class ActivityStatus {
  const ActivityStatus({
    required this.activity,
    required this.completed,
    required this.available,
  });

  final DailyActivity activity;
  final bool completed;

  /// False while the feature is still unimplemented, so it neither counts
  /// towards the total nor reads as something the user has skipped.
  final bool available;

  ActivityStatus copyWith({bool? completed, bool? available}) => ActivityStatus(
    activity: activity,
    completed: completed ?? this.completed,
    available: available ?? this.available,
  );
}

class DailyCompletion {
  const DailyCompletion(this.statuses);

  final List<ActivityStatus> statuses;

  static const empty = DailyCompletion([]);

  List<ActivityStatus> get availableStatuses =>
      statuses.where((s) => s.available).toList(growable: false);

  int get completed => availableStatuses.where((s) => s.completed).length;

  int get total => availableStatuses.length;

  /// What is still outstanding today, in the order it appears on Today.
  ///
  /// A count on its own ("6 / 7") tells you that something is missing without
  /// telling you what, which leaves you hunting the page for it.
  List<DailyActivity> get remaining => availableStatuses
      .where((s) => !s.completed)
      .map((s) => s.activity)
      .toList(growable: false);

  bool get isComplete => total > 0 && remaining.isEmpty;
}
