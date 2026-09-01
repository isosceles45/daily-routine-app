import 'dart:math';

import 'package:daily_ritual/features/games/domain/sudoku.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('generation', () {
    test('every difficulty produces a uniquely solvable puzzle', () {
      for (final difficulty in SudokuDifficulty.values) {
        final puzzle = Sudoku.generate(difficulty, Random(7));

        expect(
          Sudoku.countSolutions(puzzle.givens),
          1,
          reason: '${difficulty.name} must have exactly one solution',
        );
      }
    });

    test('the stated solution is a real solution of the clues', () {
      final puzzle = Sudoku.generate(SudokuDifficulty.hard, Random(3));

      expect(Sudoku.isComplete(puzzle.solution), isTrue);
      for (var i = 0; i < Sudoku.cells; i++) {
        if (puzzle.givens[i] != 0) {
          expect(puzzle.givens[i], puzzle.solution[i]);
        }
      }
    });

    test('clue counts land in the right band', () {
      for (final difficulty in SudokuDifficulty.values) {
        final puzzle = Sudoku.generate(difficulty, Random(11));
        final givens = puzzle.givens.where((v) => v != 0).length;

        // Removal stops early when a cell cannot go without breaking
        // uniqueness, so the target is a floor, never an exact count.
        expect(givens, greaterThanOrEqualTo(difficulty.givens));
        expect(givens, lessThan(Sudoku.cells));
      }
    });

    test('two seeds give two different puzzles', () {
      final a = Sudoku.generate(SudokuDifficulty.medium, Random(1));
      final b = Sudoku.generate(SudokuDifficulty.medium, Random(2));
      expect(a.givens, isNot(equals(b.givens)));
    });

    test('generation is fast enough to do on screen', () {
      final watch = Stopwatch()..start();
      Sudoku.generate(SudokuDifficulty.expert, Random(5));
      watch.stop();

      // Generous: the point is to catch a pathological regression, not to
      // benchmark the machine.
      expect(watch.elapsedMilliseconds, lessThan(4000));
    });
  });

  group('rules', () {
    test('rejects a repeat in row, column or box', () {
      final grid = List.filled(Sudoku.cells, 0);
      grid[0] = 5;

      expect(Sudoku.canPlace(grid, 1, 5), isFalse, reason: 'same row');
      expect(Sudoku.canPlace(grid, 9, 5), isFalse, reason: 'same column');
      expect(Sudoku.canPlace(grid, 10, 5), isFalse, reason: 'same box');
      expect(Sudoku.canPlace(grid, 40, 5), isTrue, reason: 'unrelated cell');
    });

    test('finds both halves of a clash', () {
      final grid = List.filled(Sudoku.cells, 0);
      grid[0] = 3;
      grid[8] = 3;
      expect(Sudoku.conflicts(grid), {0, 8});
    });

    test('a full but wrong grid is not complete', () {
      final grid = List.filled(Sudoku.cells, 1);
      expect(Sudoku.isComplete(grid), isFalse);
    });
  });

  group('solving', () {
    test('solves a generated puzzle back to its own solution', () {
      final puzzle = Sudoku.generate(SudokuDifficulty.easy, Random(9));
      expect(Sudoku.solve(puzzle.givens), puzzle.solution);
    });

    test('returns null for an unsolvable grid', () {
      final grid = List.filled(Sudoku.cells, 0);
      // Two 5s in the top row cannot both be right.
      grid[0] = 5;
      grid[1] = 5;
      expect(Sudoku.solve(grid), isNull);
    });
  });

  test('survives a save/restore round-trip', () {
    final puzzle = Sudoku.generate(SudokuDifficulty.medium, Random(4));
    final restored = SudokuPuzzle.fromJson(puzzle.toJson());

    expect(restored.givens, puzzle.givens);
    expect(restored.solution, puzzle.solution);
    expect(restored.difficulty, puzzle.difficulty);
  });
}
