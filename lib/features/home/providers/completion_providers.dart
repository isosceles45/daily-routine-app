import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../animals/providers/fun_providers.dart';
import '../../cat_quant/providers/cat_providers.dart';
import '../../pokemon/providers/pokemon_providers.dart';
import '../../trivia/providers/trivia_providers.dart';
import '../../wordle/providers/wordle_providers.dart';
import '../domain/daily_completion.dart';

/// Marks passive content — a Pokémon, a cat photo — as seen.
///
/// Answering trivia writes a result row, but there is nothing to "answer" for
/// the fun slot, so viewing it is the completion signal. Stored in
/// `app_settings` under a per-day key rather than a new table.
class SeenActivities extends AsyncNotifier<Set<DailyActivity>> {
  static String _key(String date, DailyActivity activity) =>
      'seen:$date:${activity.name}';

  @override
  Future<Set<DailyActivity>> build() async {
    final date = ref.watch(currentDateProvider);
    final db = ref.watch(databaseProvider);

    final seen = <DailyActivity>{};
    for (final activity in DailyActivity.values) {
      if (await db.getSetting(_key(date, activity)) != null) {
        seen.add(activity);
      }
    }
    return seen;
  }

  Future<void> markSeen(DailyActivity activity) async {
    final date = ref.read(currentDateProvider);
    final current = state.value ?? const <DailyActivity>{};
    if (current.contains(activity)) return;

    await ref.read(databaseProvider).setSetting(_key(date, activity), '1');
    state = AsyncData({...current, activity});
  }
}

final seenActivitiesProvider =
    AsyncNotifierProvider<SeenActivities, Set<DailyActivity>>(
      SeenActivities.new,
    );

/// Today's completion across every activity that currently exists.
final dailyCompletionProvider = Provider<DailyCompletion>((ref) {
  final seen =
      ref.watch(seenActivitiesProvider).value ?? const <DailyActivity>{};
  final triviaResult = ref.watch(triviaResultProvider).value;

  // A card only counts once its content actually loaded — an activity you
  // couldn't do because the API was down isn't one you skipped.
  final funLoaded = ref.watch(dailyFunProvider).hasValue;
  final pokemonLoaded = ref.watch(pokemonOfTheDayProvider).hasValue;

  final catResult = ref.watch(catResultProvider).value;
  final wordleResult = ref.watch(todayWordleProvider).value;

  // A CAT question that never arrived isn't an activity the user skipped.
  final catQuestion = ref.watch(catQuestionProvider);
  final catAvailable = catQuestion.hasValue && catQuestion.value != null;

  return DailyCompletion([
    ActivityStatus(
      activity: DailyActivity.wordle,
      // Importing a result is the completion signal — win or lose. Requiring
      // a win would punish the user for a hard word.
      completed: wordleResult != null,
      available: true,
    ),
    ActivityStatus(
      activity: DailyActivity.catQuant,
      completed: catResult?.answered ?? false,
      available: catAvailable,
    ),
    ActivityStatus(
      activity: DailyActivity.trivia,
      completed: triviaResult?.answered ?? false,
      available: true,
    ),
    ActivityStatus(
      activity: DailyActivity.fun,
      completed: seen.contains(DailyActivity.fun),
      available: funLoaded,
    ),
    ActivityStatus(
      activity: DailyActivity.pokemon,
      completed: seen.contains(DailyActivity.pokemon),
      available: pokemonLoaded,
    ),
    // Phase 3 flips these on.
    const ActivityStatus(
      activity: DailyActivity.challenge,
      completed: false,
      available: false,
    ),
    const ActivityStatus(
      activity: DailyActivity.surprise,
      completed: false,
      available: false,
    ),
  ]);
});
