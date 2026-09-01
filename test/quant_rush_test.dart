import 'dart:math';

import 'package:daily_ritual/features/games/domain/quant_rush.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every generated round is internally consistent', () {
    // Wide sweep: each generator gets hit many times with different draws.
    for (var seed = 0; seed < 400; seed++) {
      final round = QuantRush.next(Random(seed));

      expect(round.options.length, 4, reason: 'seed $seed');
      expect(
        round.options.toSet().length,
        4,
        reason: 'seed $seed has duplicate options: ${round.options}',
      );
      expect(round.answerIndex, inInclusiveRange(0, 3), reason: 'seed $seed');
      expect(round.prompt.trim(), isNotEmpty, reason: 'seed $seed');
      expect(round.topic.trim(), isNotEmpty, reason: 'seed $seed');
      expect(round.isCorrect(round.answerIndex), isTrue);
    }
  });

  test('the marked answer is the arithmetically right one', () {
    // Independently re-derive the answer from the prompt text, so a generator
    // that agrees with itself but is wrong about maths still gets caught.
    var checked = 0;

    for (var seed = 0; seed < 400; seed++) {
      final round = QuantRush.next(Random(seed));
      final expected = _evaluate(round.prompt);
      if (expected == null) continue;

      checked++;
      expect(
        double.parse(round.answer),
        closeTo(expected, 1e-9),
        reason: 'seed $seed — "${round.prompt}" marked ${round.answer}',
      );
    }

    // The parser below only understands some of the prompt shapes; make sure
    // it actually exercised a meaningful number of them.
    expect(checked, greaterThan(100));
  });

  test('rounds vary rather than repeating one template', () {
    final topics = <String>{};
    for (var seed = 0; seed < 200; seed++) {
      topics.add(QuantRush.next(Random(seed)).topic);
    }
    expect(topics.length, greaterThanOrEqualTo(5));
  });

  test('a run is a minute long', () {
    expect(QuantRush.duration, const Duration(seconds: 60));
  });
}

/// Re-derives the answer straight from the prompt, without touching the
/// generator's own arithmetic.
double? _evaluate(String prompt) {
  final multiply = RegExp(r'^(\d+) × (\d+)$').firstMatch(prompt);
  if (multiply != null) {
    return int.parse(multiply.group(1)!) * int.parse(multiply.group(2)!) * 1.0;
  }

  final square = RegExp(r'^(\d+)²$').firstMatch(prompt);
  if (square != null) {
    final n = int.parse(square.group(1)!);
    return (n * n).toDouble();
  }

  final percent = RegExp(r'^(\d+)% of (\d+)$').firstMatch(prompt);
  if (percent != null) {
    return int.parse(percent.group(1)!) * int.parse(percent.group(2)!) / 100;
  }

  final divide = RegExp(r'^(\d+) ÷ (\d+)$').firstMatch(prompt);
  if (divide != null) {
    return int.parse(divide.group(1)!) / int.parse(divide.group(2)!);
  }

  final discount = RegExp(r'^(\d+) after (\d+)% off$').firstMatch(prompt);
  if (discount != null) {
    final price = int.parse(discount.group(1)!);
    final off = int.parse(discount.group(2)!);
    return price * (100 - off) / 100;
  }

  final average = RegExp(r'^Average of (.+)$').firstMatch(prompt);
  if (average != null) {
    final parts = average.group(1)!.split(', ').map(int.parse).toList();
    return parts.reduce((a, b) => a + b) / parts.length;
  }

  final fraction = RegExp(r'^(\d+)/(\d+) of (\d+)$').firstMatch(prompt);
  if (fraction != null) {
    return int.parse(fraction.group(3)!) *
        int.parse(fraction.group(1)!) /
        int.parse(fraction.group(2)!);
  }

  return null;
}
