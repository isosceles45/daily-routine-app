import 'dart:math';

import '../../cat_quant/domain/cat_question.dart';

/// One question in a Quant Rush run: short enough to read at a glance and
/// answer in a few seconds.
class QuantRound {
  const QuantRound({
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.topic,
  });

  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String topic;

  bool isCorrect(int index) => index == answerIndex;

  String get answer => options[answerIndex];
}

/// A candidate before it is accepted.
///
/// [answer] and [crossCheck] are reached by deliberately different routes, and
/// a round whose two derivations disagree is thrown away rather than shown —
/// the same rule the CAT generator follows (§8). A timed game is exactly where
/// a wrong "correct" answer would be least likely to be noticed and most
/// infuriating, so it gets the same treatment.
class _Candidate {
  const _Candidate({
    required this.prompt,
    required this.topic,
    required this.answer,
    required this.crossCheck,
    required this.distractors,
  });

  final String prompt;
  final String topic;
  final double answer;
  final double crossCheck;
  final List<double> distractors;

  bool get selfConsistent =>
      crossCheck.isFinite && answer.isFinite && Num.agree(answer, crossCheck);
}

/// Generates short mental-arithmetic rounds.
///
/// Every generator computes its answer twice by independent routes. Nothing is
/// fetched and nothing is verified over the network, because unlike the daily
/// CAT question these are arithmetic identities the second derivation settles
/// on its own — and a 60-second game cannot wait on an HTTP round trip.
abstract final class QuantRush {
  static const duration = Duration(seconds: 60);

  /// Give up on a stubborn seed rather than looping forever.
  static const _maxAttempts = 40;

  static QuantRound next(Random rng) {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final candidate = _draw(rng);
      if (candidate == null || !candidate.selfConsistent) continue;

      final round = _toRound(candidate, rng);
      if (round != null) return round;
    }

    // Unreachable in practice; a trivially safe round beats throwing mid-game.
    return const QuantRound(
      prompt: '12 × 12',
      options: ['124', '144', '154', '134'],
      answerIndex: 1,
      topic: 'Multiplication',
    );
  }

  static _Candidate? _draw(Random rng) {
    return switch (rng.nextInt(7)) {
      0 => _multiply(rng),
      1 => _percentage(rng),
      2 => _square(rng),
      3 => _fractionOf(rng),
      4 => _discount(rng),
      5 => _average(rng),
      _ => _divide(rng),
    };
  }

  /// Turns a verified candidate into four distinct options.
  static QuantRound? _toRound(_Candidate candidate, Random rng) {
    final correct = Num.format(candidate.answer);

    final options = <String>[correct];
    for (final value in candidate.distractors) {
      if (options.length == 4) break;
      final text = Num.format(value);
      if (!options.contains(text)) options.add(text);
    }
    // Distractors collapsing onto the answer means a confusing question;
    // redraw rather than show three identical choices.
    if (options.length < 4) return null;

    final shuffled = [...options]..shuffle(rng);
    return QuantRound(
      prompt: candidate.prompt,
      options: shuffled,
      answerIndex: shuffled.indexOf(correct),
      topic: candidate.topic,
    );
  }

  // --- Generators ---------------------------------------------------------

  static _Candidate _multiply(Random rng) {
    final a = 12 + rng.nextInt(88);
    final b = 3 + rng.nextInt(16);

    final answer = (a * b).toDouble();
    // Cross-check by distributing over b's digits.
    final crossCheck = (a * (b ~/ 10) * 10 + a * (b % 10)).toDouble();

    return _Candidate(
      prompt: '$a × $b',
      topic: 'Multiplication',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [answer + a, answer - a, answer + b, answer - b * 2],
    );
  }

  static _Candidate _percentage(Random rng) {
    final percent = [5, 10, 12, 15, 20, 25, 30, 40, 60, 75][rng.nextInt(10)];
    final base = (2 + rng.nextInt(39)) * 20;

    final answer = base * percent / 100;
    // Cross-check the other way round: x% of y equals y% of x.
    final crossCheck = percent * base / 100;

    return _Candidate(
      prompt: '$percent% of $base',
      topic: 'Percentages',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [answer * 2, answer / 2, answer + base / 10, base - answer],
    );
  }

  static _Candidate _square(Random rng) {
    final n = 11 + rng.nextInt(39);

    final answer = (n * n).toDouble();
    // (n-1)² + 2n − 1 is the same square by a different route.
    final crossCheck = ((n - 1) * (n - 1) + 2 * n - 1).toDouble();

    return _Candidate(
      prompt: '$n²',
      topic: 'Squares',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [
        answer + 2 * n,
        answer - 2 * n,
        answer + 10,
        (n * (n + 1)).toDouble(),
      ],
    );
  }

  static _Candidate? _fractionOf(Random rng) {
    const fractions = [(1, 4), (3, 4), (2, 3), (1, 3), (2, 5), (3, 5), (5, 6)];
    final (num, den) = fractions[rng.nextInt(fractions.length)];

    // Keep the answer whole — mental arithmetic, not long division.
    final base = den * (4 + rng.nextInt(24));

    final answer = base * num / den;
    final crossCheck = (base / den) * num;

    return _Candidate(
      prompt: '${Num.fraction(num, den)} of $base',
      topic: 'Fractions',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [
        base * den / num,
        answer + den.toDouble(),
        answer - num.toDouble(),
        base - answer,
      ],
    );
  }

  static _Candidate _discount(Random rng) {
    final percent = [10, 15, 20, 25, 30, 40, 50][rng.nextInt(7)];
    final price = (4 + rng.nextInt(46)) * 20;

    final answer = price * (100 - percent) / 100;
    // Cross-check by subtracting the discount rather than scaling the price.
    final crossCheck = price - price * percent / 100;

    return _Candidate(
      prompt: '$price after $percent% off',
      topic: 'Discounts',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [
        price * percent / 100,
        answer + price / 10,
        answer - price / 20,
        price.toDouble(),
      ],
    );
  }

  static _Candidate _average(Random rng) {
    final count = 3 + rng.nextInt(2);
    final values = [for (var i = 0; i < count; i++) 4 + rng.nextInt(60)];

    // Force a whole-number mean so the question stays a sprint.
    final total = values.reduce((a, b) => a + b);
    final remainder = total % count;
    if (remainder != 0) values[0] += count - remainder;

    final sum = values.reduce((a, b) => a + b);
    final answer = sum / count;
    // Cross-check by averaging the deviations from the first value.
    final crossCheck =
        values.first +
        values.map((v) => v - values.first).reduce((a, b) => a + b) / count;

    return _Candidate(
      prompt: 'Average of ${values.join(', ')}',
      topic: 'Averages',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [
        answer + count,
        answer - count,
        sum.toDouble(),
        answer + values.first / 2,
      ],
    );
  }

  static _Candidate _divide(Random rng) {
    final divisor = 3 + rng.nextInt(15);
    final quotient = 4 + rng.nextInt(40);
    final dividend = divisor * quotient;

    final answer = dividend / divisor;
    final crossCheck = quotient.toDouble();

    return _Candidate(
      prompt: '$dividend ÷ $divisor',
      topic: 'Division',
      answer: answer,
      crossCheck: crossCheck,
      distractors: [
        answer + 1,
        answer - 1,
        answer * 2,
        (dividend / (divisor + 1)),
      ],
    );
  }
}
