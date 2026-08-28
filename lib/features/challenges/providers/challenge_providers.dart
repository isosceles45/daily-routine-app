import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../../animals/providers/fun_providers.dart';
import '../../japan/providers/japan_providers.dart';
import '../../pokemon/providers/pokemon_providers.dart';
import '../domain/daily_challenge.dart';

/// Today's challenge, derived from whatever content has loaded.
///
/// It deliberately does not wait for the network: if Japan and Pokémon are
/// still in flight, a content-independent challenge is chosen and the user has
/// something to do immediately.
final dailyChallengeProvider = Provider<DailyChallenge>((ref) {
  final date = ref.watch(currentDateProvider);
  return ChallengeGenerator.build(
    date: date,
    japan: ref.watch(japanOfTheDayProvider).value,
    pokemon: ref.watch(pokemonOfTheDayProvider).value,
    fun: ref.watch(dailyFunProvider).value,
  );
});

final challengeRowProvider = StreamProvider<Challenge?>((ref) {
  final date = ref.watch(currentDateProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(db.challenges)..where((t) => t.date.equals(date)))
      .watchSingleOrNull();
});

final challengeDoneProvider = Provider<bool>(
  (ref) => ref.watch(challengeRowProvider).value?.completed ?? false,
);

/// Marks the challenge done, or undoes it. The prompt is written alongside so
/// History can show what the challenge actually was.
Future<void> toggleChallenge(WidgetRef ref) async {
  final date = ref.read(currentDateProvider);
  final db = ref.read(databaseProvider);
  final challenge = ref.read(dailyChallengeProvider);
  final done = ref.read(challengeDoneProvider);

  await db.into(db.challenges).insertOnConflictUpdate(
        ChallengesCompanion.insert(
          date: date,
          prompt: challenge.text,
          completed: Value(!done),
          completedAt: Value(done ? null : DateTime.now()),
        ),
      );
}
