import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/game_kind.dart';

/// Scores and saved games.
///
/// Entirely local: the games never touch the network, which is what lets them
/// be the thing you reach for when the daily content has run out — or when
/// there is no signal at all.
class GameRepository {
  const GameRepository(this._db);

  final AppDatabase _db;

  // --- Scores -------------------------------------------------------------

  Future<void> recordScore({
    required GameKind game,
    required int score,
    required String date,
    Map<String, dynamic>? detail,
  }) {
    return _db
        .into(_db.gameScores)
        .insert(
          GameScoresCompanion.insert(
            game: game.name,
            score: score,
            date: date,
            detail: Value(detail == null ? null : jsonEncode(detail)),
            playedAt: DateTime.now(),
          ),
        );
  }

  Stream<List<GameScore>> watchScores() {
    return (_db.select(
      _db.gameScores,
    )..orderBy([(t) => OrderingTerm.desc(t.playedAt)])).watch();
  }

  // --- Saved games --------------------------------------------------------

  Future<Map<String, dynamic>?> readState(GameKind game) async {
    final row = await (_db.select(
      _db.puzzleStates,
    )..where((t) => t.game.equals(game.name))).getSingleOrNull();
    if (row == null) return null;

    try {
      return jsonDecode(row.payload) as Map<String, dynamic>;
    } on FormatException {
      // A save written by an older build must never block a new game.
      await clearState(game);
      return null;
    }
  }

  Future<void> saveState(GameKind game, Map<String, dynamic> payload) {
    return _db
        .into(_db.puzzleStates)
        .insertOnConflictUpdate(
          PuzzleStatesCompanion.insert(
            game: game.name,
            payload: jsonEncode(payload),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> clearState(GameKind game) => (_db.delete(
    _db.puzzleStates,
  )..where((t) => t.game.equals(game.name))).go();
}

/// Personal bests and how much has been played, derived from the score rows.
class GameStats {
  const GameStats({
    required this.best,
    required this.plays,
    required this.lastPlayedDate,
  });

  static const empty = GameStats(best: null, plays: 0, lastPlayedDate: null);

  /// Null until the game has been finished once.
  final int? best;

  final int plays;
  final String? lastPlayedDate;

  static Map<GameKind, GameStats> from(List<GameScore> rows) {
    final byGame = <GameKind, List<GameScore>>{};

    for (final row in rows) {
      final kind = GameKind.values.where((g) => g.name == row.game).firstOrNull;
      // A row from a game that no longer exists is ignored rather than
      // crashing the hub.
      if (kind == null) continue;
      byGame.putIfAbsent(kind, () => []).add(row);
    }

    return {
      for (final entry in byGame.entries)
        entry.key: GameStats(
          best: entry.value
              .map((r) => r.score)
              .fold<int>(0, (a, b) => a > b ? a : b),
          plays: entry.value.length,
          lastPlayedDate: entry.value.first.date,
        ),
    };
  }
}
