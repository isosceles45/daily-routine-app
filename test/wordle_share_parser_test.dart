import 'package:daily_ritual/features/wordle/domain/wordle_share.dart';
import 'package:flutter_test/flutter_test.dart';

const solved = '''Wordle 1,234 4/6

⬛⬛🟨⬛⬛
⬛🟨⬛⬛🟨
🟨🟩⬛⬛⬛
🟩🟩🟩🟩🟩''';

void main() {
  group('header', () {
    test('parses number, score and grid', () {
      final r = WordleShareParser.parse(solved)!;
      expect(r.number, 1234);
      expect(r.score, 4);
      expect(r.completed, isTrue);
      expect(r.hardMode, isFalse);
      expect(r.grid, hasLength(4));
    });

    test('strips thousands separators', () {
      expect(WordleShareParser.parse('Wordle 1,234 3/6')!.number, 1234);
      expect(WordleShareParser.parse('Wordle 1234 3/6')!.number, 1234);
      // Some locales share with a space or dot as the separator.
      expect(WordleShareParser.parse('Wordle 1 234 3/6')!.number, 1234);
      expect(WordleShareParser.parse('Wordle 1.234 3/6')!.number, 1234);
    });

    test('reads the hard-mode asterisk', () {
      expect(WordleShareParser.parse('Wordle 1,234 4/6*')!.hardMode, isTrue);
      expect(WordleShareParser.parse('Wordle 1,234 4/6')!.hardMode, isFalse);
    });

    test('treats X/6 as a failure, not a score', () {
      final r = WordleShareParser.parse('Wordle 1,234 X/6')!;
      expect(r.score, isNull);
      expect(r.completed, isFalse);
      expect(r.scoreLabel, 'X/6');
    });

    test('accepts every valid score', () {
      for (var n = 1; n <= 6; n++) {
        expect(WordleShareParser.parse('Wordle 900 $n/6')!.score, n);
      }
    });

    test('is case-insensitive and tolerates surrounding chatter', () {
      final r = WordleShareParser.parse(
        'look at this!\nwordle 1,234 4/6\n\nnice one',
      )!;
      expect(r.number, 1234);
    });
  });

  group('rejects non-shares', () {
    test('returns null rather than guessing', () {
      for (final text in [
        '',
        'just some text',
        'Wordle 1234',
        'Wordle 4/6',
        'Connections Puzzle #123',
        'Wordle 1,234 7/6',
        'Wordle 1,234 0/6',
      ]) {
        expect(WordleShareParser.parse(text), isNull, reason: 'for "$text"');
      }
    });
  });

  group('grid', () {
    test('keeps one row per guess', () {
      final r = WordleShareParser.parse(solved)!;
      expect(r.grid.last, '🟩🟩🟩🟩🟩');
      expect(r.grid.first, '⬛⬛🟨⬛⬛');
    });

    test('accepts light-mode squares', () {
      final r = WordleShareParser.parse('Wordle 1,234 1/6\n\n🟩🟩🟩🟩🟩')!;
      expect(r.grid, ['🟩🟩🟩🟩🟩']);
    });

    test('accepts the colour-blind palette', () {
      // Orange is correct and blue is present in high-contrast mode.
      final r = WordleShareParser.parse(
        'Wordle 1,234 2/6\n\n⬛🟦⬛⬛⬛\n🟧🟧🟧🟧🟧',
      )!;
      expect(r.grid, hasLength(2));
      expect(WordleShareParser.tileState('🟧'), 'correct');
      expect(WordleShareParser.tileState('🟦'), 'present');
    });

    test('a failed board carries six rows', () {
      final rows = List.filled(6, '⬛⬛⬛⬛⬛').join('\n');
      final r = WordleShareParser.parse('Wordle 1,234 X/6\n\n$rows')!;
      expect(r.grid, hasLength(6));
    });

    test('drops a grid that disagrees with the score', () {
      // Five rows for a 4/6 means we cannot trust the board; the score is
      // still readable, so the result survives without it.
      final rows = List.filled(5, '⬛⬛⬛⬛⬛').join('\n');
      final r = WordleShareParser.parse('Wordle 1,234 4/6\n\n$rows')!;
      expect(r.score, 4);
      expect(r.grid, isEmpty);
    });

    test('ignores stray emoji that are not five-tile rows', () {
      final r = WordleShareParser.parse(
        'Wordle 1,234 1/6 🟩🟩\n\n🟩🟩🟩🟩🟩\n\nso close 🟨',
      )!;
      expect(r.grid, ['🟩🟩🟩🟩🟩']);
    });

    test('a share with no grid still parses', () {
      final r = WordleShareParser.parse('Wordle 1,234 4/6')!;
      expect(r.grid, isEmpty);
      expect(r.score, 4);
    });
  });

  group('number to date', () {
    test('anchors on the known epoch', () {
      // Puzzle #0 was 19 June 2021 — the original game numbered from zero.
      expect(WordleShareParser.dateFor(0), '2021-06-19');
      expect(WordleShareParser.dateFor(1), '2021-06-20');
    });

    test('matches a real published puzzle', () {
      // Verified against NYT: #1896 was Friday 28 August 2026. An off-by-one
      // here files every imported result under the wrong day, so this is
      // pinned to a real-world checkpoint rather than to our own arithmetic.
      expect(WordleShareParser.dateFor(1896), '2026-08-28');
      expect(WordleShareParser.numberFor('2026-08-28'), 1896);
      expect(WordleShareParser.numberFor('2026-08-29'), 1897);
    });

    test('round-trips', () {
      for (final n in [1, 500, 1000, 1234, 2000]) {
        expect(WordleShareParser.numberFor(WordleShareParser.dateFor(n)), n);
      }
    });

    test('files a pasted result under the day it belongs to', () {
      // Pasting yesterday's share must not be recorded as today's.
      final r = WordleShareParser.parse('Wordle 1896 3/6')!;
      expect(r.date, '2026-08-28');
    });
  });
}
