import 'dart:math';

import 'package:daily_ritual/features/games/domain/game_2048.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a board from four rows, so the tests read like the grid they mean.
Game2048 board(List<List<int>> rows, {int score = 0}) =>
    Game2048(tiles: [for (final row in rows) ...row], score: score);

List<List<int>> rowsOf(Game2048 game) => [
  for (var r = 0; r < 4; r++) game.tiles.sublist(r * 4, r * 4 + 4),
];

/// Counts tiles, so a spawn can be told apart from a merge.
int filled(Game2048 g) => g.tiles.where((v) => v != 0).length;

void main() {
  group('sliding', () {
    test('packs a row to the left without merging unequal tiles', () {
      final g = board([
        [0, 2, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(SwipeDirection.left, Random(1));

      expect(rowsOf(g)[0], [2, 4, 0, 0]);
    });

    test('merges equal neighbours and scores the total', () {
      final g = board([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(SwipeDirection.left, Random(1));

      expect(rowsOf(g)[0].first, 4);
      expect(g.score, 4);
    });

    test('a merged tile cannot merge again in the same move', () {
      // [2,2,4] must become [4,4], never [8].
      final g = board([
        [2, 2, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(SwipeDirection.left, Random(1));

      expect(rowsOf(g)[0].take(2).toList(), [4, 4]);
      expect(g.score, 4);
    });

    test('four equal tiles merge into two pairs', () {
      final g = board([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(SwipeDirection.left, Random(1));

      expect(rowsOf(g)[0].take(2).toList(), [4, 4]);
      expect(g.score, 8);
    });

    test('merging right pairs from the right-hand end', () {
      final g = board([
        [2, 2, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(SwipeDirection.right, Random(1));

      expect(rowsOf(g)[0].sublist(2), [4, 4]);
    });

    test('moves work vertically too', () {
      final g = board([
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(SwipeDirection.up, Random(1));

      expect(g.tiles[0], 4);
      expect(g.score, 4);
    });
  });

  group('spawning', () {
    test('a move that changes nothing spawns nothing', () {
      final start = board([
        [2, 4, 8, 16],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final after = start.move(SwipeDirection.left, Random(1));

      expect(identical(after, start), isTrue);
      expect(filled(after), filled(start));
    });

    test('a real move adds exactly one tile', () {
      final start = board([
        [0, 2, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]);
      final after = start.move(SwipeDirection.left, Random(1));

      expect(filled(after), filled(start) + 1);
    });

    test('a new game starts with two tiles', () {
      expect(filled(Game2048.start(Random(3))), 2);
    });
  });

  group('game over', () {
    test('a full board with no equal neighbours is over', () {
      final g = board([
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ]);
      expect(g.isGameOver, isTrue);
    });

    test('a full board with a possible merge is not over', () {
      final g = board([
        [2, 2, 4, 8],
        [4, 8, 16, 32],
        [2, 4, 8, 16],
        [4, 8, 16, 32],
      ]);
      expect(g.isGameOver, isFalse);
    });

    test('an empty cell always means the game continues', () {
      expect(
        board([
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ]).isGameOver,
        isFalse,
      );
    });
  });

  test('reaching 2048 is recorded but does not end the game', () {
    final g = board([
      [1024, 1024, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]).move(SwipeDirection.left, Random(1));

    expect(g.best2048Reached, isTrue);
    expect(g.highestTile, 2048);
    expect(g.isGameOver, isFalse);
  });

  test('survives a save/restore round-trip', () {
    final g = Game2048.start(Random(8)).move(SwipeDirection.left, Random(2));
    final restored = Game2048.fromJson(g.toJson());

    expect(restored.tiles, g.tiles);
    expect(restored.score, g.score);
  });
}
