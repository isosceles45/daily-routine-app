import '../../../core/database/database.dart';
import '../../../core/dates/daily_date_service.dart';
import '../../../shared/widgets/ritual_icon.dart';

/// A date the user is counting down to, with the counting done.
///
/// Wraps the raw row rather than replacing it, so the countdown arithmetic
/// lives in one place instead of being recomputed in every widget that wants
/// to show "12 days to go".
class Countdown {
  const Countdown({required this.event, required this.today});

  final Event event;

  /// The date the countdown is measured *from*, always the app's current date
  /// rather than `DateTime.now()` — so a countdown rolls over at the same
  /// moment everything else in the app does.
  final String today;

  String get id => event.id;
  String get title => event.title;
  String get date => event.date;
  String? get note => event.note;
  bool get pinned => event.pinned;

  /// Whole calendar days from today to the event. Negative once it has passed.
  int get days => DailyDateService.daysBetween(today, event.date);

  bool get isToday => days == 0;
  bool get isPast => days < 0;
  bool get isFuture => days > 0;

  /// How it reads on the card: the number is the point, so it leads.
  String get headline => switch (days) {
    0 => 'Today',
    1 => 'Tomorrow',
    -1 => 'Yesterday',
    final d when d > 1 => '$d days',
    final d => '${-d} days ago',
  };

  /// The line under the headline.
  String get subtitle => switch (days) {
    0 => 'It is happening',
    1 => 'One more sleep',
    final d when d > 1 => 'to go',
    _ => 'passed',
  };

  /// Long countdowns are easier to feel in weeks.
  String? get weeksHint {
    if (days < 14) return null;
    final weeks = days ~/ 7;
    final spare = days % 7;
    return spare == 0
        ? 'about $weeks weeks'
        : 'about $weeks weeks and $spare day${spare == 1 ? '' : 's'}';
  }

  /// The `emoji` column now stores a [RitualIcons] name; anything it does not
  /// recognise — including a literal emoji written by an older build — falls
  /// back to the calendar rather than rendering nothing.
  RitualIcons get icon =>
      RitualIcons.byName(event.emoji) ?? RitualIcons.calendar;

  /// The weekday it lands on — genuinely useful when planning a trip.
  String get weekday => DailyDateService.weekdayName(event.date);

  String get calendarLabel => DailyDateService.monthDay(event.date);

  /// Sort key: upcoming events first, soonest first; past events last,
  /// most recent first. Pinned events lead within their group.
  static int compare(Countdown a, Countdown b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
    return a.isPast ? b.days.compareTo(a.days) : a.days.compareTo(b.days);
  }
}
