import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../data/game_repository.dart';
import '../domain/game_kind.dart';

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(ref.watch(databaseProvider)),
);

final gameScoresProvider = StreamProvider<List<GameScore>>(
  (ref) => ref.watch(gameRepositoryProvider).watchScores(),
);

/// Personal bests per game, for the hub.
final gameStatsProvider = Provider<Map<GameKind, GameStats>>((ref) {
  final rows = ref.watch(gameScoresProvider).value ?? const <GameScore>[];
  return GameStats.from(rows);
});

/// Whether anything was played today — used by Today to nudge, not to score.
///
/// Games are deliberately *not* a daily activity: making them count towards
/// completion would turn the one part of the app you play for fun into another
/// box to tick.
final playedTodayProvider = Provider<bool>((ref) {
  final today = ref.watch(currentDateProvider);
  final rows = ref.watch(gameScoresProvider).value ?? const <GameScore>[];
  return rows.any((r) => r.date == today);
});
