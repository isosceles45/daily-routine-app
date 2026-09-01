import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../data/gym_repository.dart';
import '../data/wger_service.dart';
import '../domain/workout.dart';

final wgerServiceProvider = Provider<WgerService>(
  (ref) => WgerService(ref.watch(apiClientProvider)),
);

final gymRepositoryProvider = Provider<GymRepository>(
  (ref) => GymRepository(
    ref.watch(wgerServiceProvider),
    ref.watch(databaseProvider),
  ),
);

final weeklySplitProvider = StreamProvider<WeeklySplit>(
  (ref) => ref.watch(gymRepositoryProvider).watchSplit(),
);

/// What today trains.
final todayFocusProvider = Provider<MuscleFocus>((ref) {
  final date = ref.watch(currentDateProvider);
  final split = ref.watch(weeklySplitProvider).value ?? WeeklySplit.defaults;
  return split.focusOn(date);
});

/// Today's suggested exercises. Empty on a rest day, and empty rather than
/// an error when wger cannot be reached — a missing suggestion list must not
/// stop you logging the session you actually did.
final todaySessionProvider = FutureProvider<List<Exercise>>((ref) async {
  final date = ref.watch(currentDateProvider);
  final focus = ref.watch(todayFocusProvider);
  return ref.watch(gymRepositoryProvider).sessionFor(date, focus);
});

final todayWorkoutLogProvider = StreamProvider<WorkoutLog?>((ref) {
  final date = ref.watch(currentDateProvider);
  return ref.watch(gymRepositoryProvider).watchLog(date);
});

/// Which exercises have been ticked off today.
final todayDoneProvider = Provider<Set<String>>((ref) {
  return GymRepository.doneFrom(ref.watch(todayWorkoutLogProvider).value);
});

/// Whether today's session counts as done.
final workoutDoneProvider = Provider<bool>(
  (ref) => ref.watch(todayDoneProvider).isNotEmpty,
);

final allWorkoutLogsProvider = StreamProvider<List<WorkoutLog>>(
  (ref) => ref.watch(gymRepositoryProvider).watchAllLogs(),
);
