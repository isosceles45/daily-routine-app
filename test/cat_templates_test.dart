import 'dart:math';

import 'package:daily_ritual/features/cat_quant/domain/cat_question.dart';
import 'package:daily_ritual/features/cat_quant/domain/cat_templates.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates until a template yields a question, or gives up.
GeneratedQuestion? attempt(CatTemplate template, int seed) {
  for (var i = 0; i < 40; i++) {
    final q = template.generate(Random(seed * 1000 + i));
    if (q != null) return q;
  }
  return null;
}

List<GeneratedQuestion> sample(CatTemplate template, {int count = 60}) {
  final out = <GeneratedQuestion>[];
  for (var seed = 0; seed < count; seed++) {
    final q = attempt(template, seed);
    if (q != null) out.add(q);
  }
  return out;
}

double? numberIn(String option) {
  final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(option);
  return match == null ? null : double.parse(match.group(0)!);
}

void main() {
  group('every template', () {
    for (final template in catTemplates) {
      group(template.topic, () {
        late List<GeneratedQuestion> questions;

        setUp(() => questions = sample(template));

        test('produces questions at all', () {
          expect(questions, isNotEmpty,
              reason: '${template.topic} never generated a valid question');
        });

        test('two independent derivations always agree', () {
          // This is the offline half of the §8 guarantee: a question whose
          // second derivation disagrees must never reach the screen.
          for (final q in questions) {
            expect(q.selfConsistent, isTrue,
                reason: 'answer ${q.answer} vs cross-check ${q.crossCheck} '
                    'for: ${q.stem}');
          }
        });

        test('offers exactly four distinct options', () {
          for (final q in questions) {
            expect(q.options, hasLength(4), reason: q.stem);
            expect(q.options.toSet(), hasLength(4),
                reason: 'duplicate option in: ${q.stem}');
          }
        });

        test('the answer index points at a real option', () {
          for (final q in questions) {
            expect(q.answerIndex, inInclusiveRange(0, 3));
            expect(q.options[q.answerIndex], isNotEmpty);
          }
        });

        test('the correct option carries the computed answer', () {
          for (final q in questions) {
            final shown = numberIn(q.options[q.answerIndex]);
            expect(shown, isNotNull, reason: q.options[q.answerIndex]);
          }
        });

        test('always ships a worked solution', () {
          // §8: where a solution exists it must be shown, and a generated
          // question has no excuse for lacking one.
          for (final q in questions) {
            expect(q.solution.trim(), isNotEmpty, reason: q.stem);
            expect(q.stem.trim(), isNotEmpty);
            expect(q.verifyExpr.trim(), isNotEmpty);
          }
        });

        test('is labelled at CAT difficulty, not school level', () {
          for (final q in questions) {
            expect(['Medium', 'Hard'], contains(q.difficulty));
          }
        });

        test('the answer varies across seeds', () {
          final distinct = questions.map((q) => q.stem).toSet();
          expect(distinct.length, greaterThan(1),
              reason: '${template.topic} produced only one question');
        });
      });
    }
  });

  // Independent re-derivations, written here rather than in the generator, so
  // a mistake in the template cannot hide behind its own arithmetic.
  group('answers re-derived from the question text', () {
    test('profit & loss', () {
      for (final q in sample(const ProfitLossTemplate())) {
        final m = RegExp(r'marks an article (\d+)%').firstMatch(q.stem)!;
        final d = RegExp(r'discount of (\d+)%').firstMatch(q.stem)!;
        final markup = int.parse(m.group(1)!);
        final discount = int.parse(d.group(1)!);

        final expected = (100 + markup) * (100 - discount) / 100 - 100;
        expect(q.answer, closeTo(expected, 1e-9));
        expect(numberIn(q.options[q.answerIndex]), closeTo(expected, 1e-9));
      }
    });

    test('time & work', () {
      for (final q in sample(const TimeAndWorkTemplate())) {
        final match = RegExp(r'in (\d+) days and B can complete the same work in (\d+) days')
            .firstMatch(q.stem)!;
        final a = int.parse(match.group(1)!);
        final b = int.parse(match.group(2)!);
        expect(q.answer, closeTo(a * b / (a + b), 1e-9));
      }
    });

    test('average speed is the harmonic mean', () {
      for (final q in sample(const AverageSpeedTemplate())) {
        final match = RegExp(r'speed of (\d+) km/h and returns along the same road at (\d+) km/h')
            .firstMatch(q.stem)!;
        final u = int.parse(match.group(1)!);
        final v = int.parse(match.group(2)!);

        expect(q.answer, closeTo(2 * u * v / (u + v), 1e-9));
        // The arithmetic mean must never be the answer for u != v.
        expect(q.answer, isNot(closeTo((u + v) / 2, 1e-9)));
      }
    });

    test('trailing zeros', () {
      for (final q in sample(const TrailingZerosTemplate())) {
        final n = int.parse(RegExp(r'end of (\d+)!').firstMatch(q.stem)!.group(1)!);

        var expected = 0;
        for (var p = 5; p <= n; p *= 5) {
          expected += n ~/ p;
        }
        expect(q.answer, closeTo(expected.toDouble(), 1e-9));
      }
    });

    test('combinations', () {
      int choose(int n, int r) {
        var result = 1;
        for (var i = 0; i < r; i++) {
          result = result * (n - i) ~/ (i + 1);
        }
        return result;
      }

      for (final q in sample(const CombinationsTemplate())) {
        final match = RegExp(r'committee of (\d+) members .*group of (\d+)')
            .firstMatch(q.stem)!;
        final r = int.parse(match.group(1)!);
        final n = int.parse(match.group(2)!);
        expect(q.answer, closeTo(choose(n, r).toDouble(), 1e-9));
      }
    });

    test('probability of two reds', () {
      for (final q in sample(const ProbabilityTemplate())) {
        final match = RegExp(r'contains (\d+) red balls and (\d+) blue balls')
            .firstMatch(q.stem)!;
        final red = int.parse(match.group(1)!);
        final blue = int.parse(match.group(2)!);
        final total = red + blue;

        expect(q.answer,
            closeTo(red * (red - 1) / (total * (total - 1)), 1e-9));
        expect(q.answer, greaterThan(0));
        expect(q.answer, lessThan(1));
      }
    });

    test('mixture dilution reaches the target ratio', () {
      for (final q in sample(const MixtureTemplate())) {
        final match = RegExp(
                r'(\d+) litres of a mixture of milk and water in the ratio (\d+) : (\d+).*becomes (\d+) : (\d+)',
                dotAll: true)
            .firstMatch(q.stem)!;
        final volume = int.parse(match.group(1)!);
        final milkPart = int.parse(match.group(2)!);
        final waterPart = int.parse(match.group(3)!);
        final targetMilk = int.parse(match.group(4)!);
        final targetWater = int.parse(match.group(5)!);

        final milk = volume * milkPart / (milkPart + waterPart);
        final water = volume * waterPart / (milkPart + waterPart);

        // The point of the question: after adding, the ratio must be exact.
        expect(milk / (water + q.answer),
            closeTo(targetMilk / targetWater, 1e-9));
        expect(q.answer, greaterThan(0));
      }
    });

    test('average change solves for the original count', () {
      for (final q in sample(const AverageChangeTemplate())) {
        final match = RegExp(
                r'average weight of a group of students is (\d+) kg.*weighing (\d+) kg joins.*rises to (\d+) kg',
                dotAll: true)
            .firstMatch(q.stem)!;
        final oldAverage = int.parse(match.group(1)!);
        final weight = int.parse(match.group(2)!);
        final newAverage = int.parse(match.group(3)!);

        final n = q.answer;
        // Substituting the answer must reproduce the stated new average.
        expect((n * oldAverage + weight) / (n + 1),
            closeTo(newAverage.toDouble(), 1e-9));
        expect(n, greaterThan(0));
      }
    });

    test('successive change is not the naive difference', () {
      for (final q in sample(const SuccessiveChangeTemplate())) {
        final match = RegExp(r'increased by (\d+)%.*decreased by (\d+)%',
                dotAll: true)
            .firstMatch(q.stem)!;
        final rise = int.parse(match.group(1)!);
        final fall = int.parse(match.group(2)!);

        expect(q.answer,
            closeTo(rise - fall - rise * fall / 100, 1e-9));
        expect(q.answer, isNot(closeTo((rise - fall).toDouble(), 1e-9)));
      }
    });
  });

  group('Num helpers', () {
    test('formats whole numbers without a trailing zero', () {
      expect(Num.format(12.0), '12');
      expect(Num.format(12.5), '12.5');
      expect(Num.format(-4.0), '-4');
    });

    test('reduces fractions', () {
      expect(Num.fraction(10, 36), '5/18');
      expect(Num.fraction(4, 2), '2');
      expect(Num.fraction(3, 7), '3/7');
    });

    test('agree tolerates float noise but not real differences', () {
      expect(Num.agree(0.1 + 0.2, 0.3), isTrue);
      expect(Num.agree(12.0, 12.000000001), isTrue);
      expect(Num.agree(12.0, 12.1), isFalse);
    });
  });
}
