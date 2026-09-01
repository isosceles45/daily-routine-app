import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../data/event_repository.dart';
import '../domain/countdown.dart';

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepository(ref.watch(databaseProvider)),
);

final eventsProvider = StreamProvider<List<Event>>(
  (ref) => ref.watch(eventRepositoryProvider).watchAll(),
);

/// Every event with its countdown computed against today, correctly ordered.
final countdownsProvider = Provider<List<Countdown>>((ref) {
  final today = ref.watch(currentDateProvider);
  final events = ref.watch(eventsProvider).value ?? const <Event>[];

  final countdowns = [
    for (final event in events) Countdown(event: event, today: today),
  ]..sort(Countdown.compare);

  return countdowns;
});

/// The one to put on Today — the soonest thing still ahead of you.
final nextCountdownProvider = Provider<Countdown?>((ref) {
  final upcoming = ref
      .watch(countdownsProvider)
      .where((c) => !c.isPast)
      .toList(growable: false);
  return upcoming.isEmpty ? null : upcoming.first;
});
