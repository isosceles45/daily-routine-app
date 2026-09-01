import '../../../core/dates/daily_date_service.dart';
import '../../../shared/widgets/ritual_icon.dart';

/// What a training day trains.
///
/// The wger category id travels with the focus so a split entry knows how to
/// fetch its own suggestions — the UI never has to map a name to an id.
enum MuscleFocus {
  rest('Rest', null, RitualIcons.rest),
  chest('Chest', 11, RitualIcons.chest),
  back('Back', 12, RitualIcons.back),
  legs('Legs', 9, RitualIcons.legs),
  shoulders('Shoulders', 13, RitualIcons.shoulders),
  arms('Arms', 8, RitualIcons.arms),
  abs('Abs', 10, RitualIcons.abs),
  calves('Calves', 14, RitualIcons.calves),
  cardio('Cardio', 15, RitualIcons.cardio);

  const MuscleFocus(this.label, this.wgerCategory, this.icon);

  final String label;

  /// Null for [rest]: there is nothing to suggest for a day off.
  final int? wgerCategory;

  final RitualIcons icon;

  bool get isRest => this == MuscleFocus.rest;

  static MuscleFocus fromName(String? name) => MuscleFocus.values.firstWhere(
    (f) => f.name == name,
    orElse: () => MuscleFocus.rest,
  );
}

/// One exercise suggested for a session.
class Exercise {
  const Exercise({required this.id, required this.name, this.description});

  final int id;
  final String name;

  /// wger's description, already stripped of the HTML it ships as.
  final String? description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}

/// The user's weekly training split: what each weekday trains.
class WeeklySplit {
  const WeeklySplit(this.byWeekday);

  /// `DateTime.monday` (1) … `DateTime.sunday` (7).
  final Map<int, MuscleFocus> byWeekday;

  /// A conventional push/pull/legs-ish week, used until the user edits it.
  ///
  /// Having a real default matters: an empty split would make the feature
  /// look broken on the day it is switched on.
  static const defaults = WeeklySplit({
    DateTime.monday: MuscleFocus.chest,
    DateTime.tuesday: MuscleFocus.back,
    DateTime.wednesday: MuscleFocus.legs,
    DateTime.thursday: MuscleFocus.shoulders,
    DateTime.friday: MuscleFocus.arms,
    DateTime.saturday: MuscleFocus.abs,
    DateTime.sunday: MuscleFocus.rest,
  });

  MuscleFocus focusFor(int weekday) => byWeekday[weekday] ?? MuscleFocus.rest;

  MuscleFocus focusOn(String date) =>
      focusFor(DailyDateService.parse(date).weekday);

  /// How many days a week actually train something.
  int get trainingDays => byWeekday.values.where((f) => !f.isRest).length;

  WeeklySplit withFocus(int weekday, MuscleFocus focus) =>
      WeeklySplit({...byWeekday, weekday: focus});

  static const weekdayOrder = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  static String shortName(int weekday) => switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    _ => 'Sun',
  };
}
