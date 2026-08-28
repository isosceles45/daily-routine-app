import 'dart:math';

import 'cat_question.dart';

/// One generated item, before verification.
class GeneratedQuestion {
  const GeneratedQuestion({
    required this.topic,
    required this.difficulty,
    required this.stem,
    required this.solution,
    required this.options,
    required this.answerIndex,
    required this.answer,
    required this.crossCheck,
    required this.verifyExpr,
  });

  final String topic;
  final String difficulty;
  final String stem;
  final String solution;
  final List<String> options;
  final int answerIndex;

  /// The answer from the template's primary derivation.
  final double answer;

  /// The same answer reached a second, independent way — either a different
  /// algebraic route or by substituting back into the original condition.
  /// NaN means the check failed and the question must be thrown away.
  final double crossCheck;

  /// A math.js expression that evaluates to [answer], used for the online
  /// verification pass (§8).
  final String verifyExpr;

  /// Whether the two offline derivations agree. A question that fails this is
  /// never shown, online or off.
  bool get selfConsistent => crossCheck.isFinite && Num.agree(answer, crossCheck);
}

abstract class CatTemplate {
  const CatTemplate();

  String get topic;
  String get difficulty;

  /// Returns null when the random parameters didn't produce a clean question;
  /// the generator simply tries again with a different draw.
  GeneratedQuestion? generate(Random rng);
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

T _pick<T>(Random rng, List<T> items) => items[rng.nextInt(items.length)];

/// Assembles four distinct options and reports where the correct one landed.
///
/// Returns null when the distractors collapsed onto the answer — better to
/// regenerate than to show a question with a duplicated option.
({List<String> options, int index})? _options(
  String correct,
  List<String> distractors,
  Random rng,
) {
  final unique = <String>[correct];
  for (final d in distractors) {
    if (unique.length == 4) break;
    if (!unique.contains(d)) unique.add(d);
  }
  if (unique.length < 4) return null;

  final shuffled = [...unique]..shuffle(rng);
  return (options: shuffled, index: shuffled.indexOf(correct));
}

int _combinations(int n, int r) {
  if (r < 0 || r > n) return 0;
  var result = 1;
  for (var i = 0; i < r; i++) {
    result = result * (n - i) ~/ (i + 1);
  }
  return result;
}

double _factorial(int n) {
  var result = 1.0;
  for (var i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

int _permutations(int n, int r) {
  var result = 1;
  for (var i = 0; i < r; i++) {
    result *= n - i;
  }
  return result;
}

// ---------------------------------------------------------------------------
// Templates
// ---------------------------------------------------------------------------

/// Mark up, then discount — the classic overall-profit question.
class ProfitLossTemplate extends CatTemplate {
  const ProfitLossTemplate();

  @override
  String get topic => 'Profit & Loss';
  @override
  String get difficulty => 'Medium';

  @override
  GeneratedQuestion? generate(Random rng) {
    final markup = _pick(rng, [25, 40, 50, 60, 75, 80]);
    final discount = _pick(rng, [10, 20, 25, 40]);

    // Normalise cost price to 100.
    final selling = (100 + markup) * (100 - discount) / 100;
    final profit = selling - 100;
    if (profit <= 0) return null;

    // Independent route: run the same trade on a concrete cost price.
    const cost = 400.0;
    final marked = cost * (100 + markup) / 100;
    final sold = marked * (100 - discount) / 100;
    final cross = (sold - cost) / cost * 100;

    final correct = Num.percent(profit);
    final built = _options(
      correct,
      [
        // Subtracting the percentages is the mistake this question is for.
        Num.percent((markup - discount).toDouble()),
        Num.percent((markup + discount).toDouble()),
        Num.percent(markup * discount / 100),
        Num.percent(profit + 2),
      ].where((s) => !s.startsWith('-')).toList(),
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'A shopkeeper marks an article $markup% above its cost price and '
          'then allows a discount of $discount% on the marked price. What is '
          'his overall profit percentage?',
      solution: 'Take the cost price as 100. '
          'Marked price = ${100 + markup}. '
          'Selling price = ${100 + markup} × ${100 - discount}/100 = '
          '${Num.format(selling)}. '
          'Profit = ${Num.format(selling)} − 100 = ${Num.format(profit)}, '
          'so the profit percentage is ${Num.percent(profit)}. '
          'Note it is not $markup − $discount%: the discount applies to the '
          'marked price, not the cost.',
      options: built.options,
      answerIndex: built.index,
      answer: profit,
      crossCheck: cross,
      verifyExpr: '(100+$markup)*(100-$discount)/100 - 100',
    );
  }
}

/// Two workers, combined rate.
class TimeAndWorkTemplate extends CatTemplate {
  const TimeAndWorkTemplate();

  @override
  String get topic => 'Time & Work';
  @override
  String get difficulty => 'Medium';

  @override
  GeneratedQuestion? generate(Random rng) {
    const pool = [6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 30, 36, 40, 45];
    final a = _pick(rng, pool);
    final b = _pick(rng, pool);
    if (a == b) return null;

    // Keep the answer a whole number of days.
    if ((a * b) % (a + b) != 0) return null;
    final together = a * b / (a + b);

    // Independent route: add the rates rather than combining the times.
    final cross = 1 / (1 / a + 1 / b);

    final correct = '${Num.format(together)} days';
    final built = _options(
      correct,
      [
        '${Num.format((a + b) / 2)} days',
        '${Num.format((a + b).toDouble())} days',
        '${Num.format((a - b).abs().toDouble())} days',
        '${Num.format(together + 1)} days',
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'A can complete a piece of work in $a days and B can complete the '
          'same work in $b days. If they work together, in how many days will '
          'the work be finished?',
      solution: "A's one-day work = 1/$a and B's = 1/$b. "
          'Together they do 1/$a + 1/$b = ${a + b}/${a * b} of the work per '
          'day. So the whole work takes ${a * b}/${a + b} = '
          '${Num.format(together)} days.',
      options: built.options,
      answerIndex: built.index,
      answer: together,
      crossCheck: cross,
      verifyExpr: '$a*$b/($a+$b)',
    );
  }
}

/// Out at one speed, back at another — harmonic mean, not arithmetic.
class AverageSpeedTemplate extends CatTemplate {
  const AverageSpeedTemplate();

  @override
  String get topic => 'Time, Speed & Distance';
  @override
  String get difficulty => 'Medium';

  @override
  GeneratedQuestion? generate(Random rng) {
    const pool = [20, 30, 40, 50, 60, 75, 80, 90, 100, 120];
    final u = _pick(rng, pool);
    final v = _pick(rng, pool);
    if (u == v) return null;

    final average = 2 * u * v / (u + v);
    if ((average - average.roundToDouble()).abs() > 1e-9) return null;

    // Independent route: put a concrete distance on it and use total/total.
    final distance = (u * v * 3).toDouble();
    final cross = 2 * distance / (distance / u + distance / v);

    final correct = '${Num.format(average)} km/h';
    final built = _options(
      correct,
      [
        // The arithmetic mean is the trap this question exists to catch.
        '${Num.format((u + v) / 2)} km/h',
        '${Num.format(average + 2)} km/h',
        '${Num.format(u.toDouble())} km/h',
        '${Num.format(average - 2)} km/h',
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'A car travels from town P to town Q at a uniform speed of $u km/h '
          'and returns along the same road at $v km/h. What is its average '
          'speed for the entire journey?',
      solution: 'Let the one-way distance be d. '
          'Time out = d/$u, time back = d/$v, total distance = 2d. '
          'Average speed = 2d ÷ (d/$u + d/$v) = 2 × $u × $v / ($u + $v) = '
          '${Num.format(average)} km/h. '
          'It is the harmonic mean, not ($u + $v)/2 — equal distances are '
          'covered in unequal times.',
      options: built.options,
      answerIndex: built.index,
      answer: average,
      crossCheck: cross,
      verifyExpr: '2*$u*$v/($u+$v)',
    );
  }
}

/// A rise followed by a fall — successive percentage change.
class SuccessiveChangeTemplate extends CatTemplate {
  const SuccessiveChangeTemplate();

  @override
  String get topic => 'Percentages';
  @override
  String get difficulty => 'Medium';

  static String _label(double change) {
    if (change.abs() < 1e-9) return 'No change';
    final word = change > 0 ? 'increase' : 'decrease';
    return '${Num.format(change.abs())}% $word';
  }

  @override
  GeneratedQuestion? generate(Random rng) {
    final rise = _pick(rng, [10, 20, 25, 30, 40, 50]);
    final fall = _pick(rng, [10, 20, 25, 30, 40]);

    final net = rise - fall - rise * fall / 100;
    if (net.abs() < 1e-9) return null;

    // Independent route: apply both multipliers to a concrete price.
    const price = 200.0;
    final after = price * (1 + rise / 100) * (1 - fall / 100);
    final cross = (after - price) / price * 100;

    final correct = _label(net);
    final built = _options(
      correct,
      [
        _label((rise - fall).toDouble()),
        _label((fall - rise).toDouble()),
        _label(-(rise * fall / 100)),
        _label(net > 0 ? net + 2 : net - 2),
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'The price of a commodity is first increased by $rise% and then '
          'the new price is decreased by $fall%. What is the net percentage '
          'change in the original price?',
      solution: 'Take the original price as 100. '
          'After the rise it is ${Num.format(100 * (1 + rise / 100))}. '
          'After the fall it is '
          '${Num.format(100 * (1 + rise / 100) * (1 - fall / 100))}. '
          'The net change is ${Num.format(net)}%, i.e. ${_label(net)}. '
          'The shortcut is $rise − $fall − ($rise × $fall)/100.',
      options: built.options,
      answerIndex: built.index,
      answer: net,
      crossCheck: cross,
      verifyExpr: '100*(1+$rise/100)*(1-$fall/100) - 100',
    );
  }
}

/// Trailing zeros of a factorial — Legendre's formula.
class TrailingZerosTemplate extends CatTemplate {
  const TrailingZerosTemplate();

  @override
  String get topic => 'Number Systems';
  @override
  String get difficulty => 'Hard';

  @override
  GeneratedQuestion? generate(Random rng) {
    final n = _pick(rng, [50, 60, 75, 80, 100, 120, 125, 150, 200, 250]);

    // Primary: sum of floor(n / 5^k).
    var zeros = 0;
    var power = 5;
    final terms = <String>[];
    while (power <= n) {
      zeros += n ~/ power;
      terms.add('floor($n/$power)');
      power *= 5;
    }

    // Independent route: count the factors of five in every term of n!.
    var counted = 0;
    for (var i = 5; i <= n; i += 5) {
      var value = i;
      while (value % 5 == 0) {
        counted++;
        value ~/= 5;
      }
    }

    final correct = '$zeros';
    final built = _options(
      correct,
      ['${n ~/ 5}', '${zeros + 1}', '${zeros - 1}', '${zeros + 2}'],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'How many consecutive zeros are there at the end of $n! '
          '(that is, $n factorial)?',
      solution: 'Each trailing zero comes from a factor of 10 = 2 × 5, and '
          'fives are scarcer than twos, so count the fives: '
          '${terms.join(' + ')} = $zeros. '
          'Note ${n ~/ 5} alone is not enough — multiples of 25 contribute a '
          'second five, multiples of 125 a third.',
      options: built.options,
      answerIndex: built.index,
      answer: zeros.toDouble(),
      crossCheck: counted.toDouble(),
      verifyExpr: terms.join('+'),
    );
  }
}

/// Committee selection.
class CombinationsTemplate extends CatTemplate {
  const CombinationsTemplate();

  @override
  String get topic => 'Permutation & Combination';
  @override
  String get difficulty => 'Hard';

  @override
  GeneratedQuestion? generate(Random rng) {
    final n = _pick(rng, [8, 9, 10, 11, 12]);
    final r = _pick(rng, [2, 3, 4]);
    if (r >= n) return null;

    // Primary: the multiplicative form, which stays in integers.
    final ways = _combinations(n, r);

    // Independent route: the factorial ratio.
    final cross = _factorial(n) / (_factorial(r) * _factorial(n - r));

    final correct = '$ways';
    final built = _options(
      correct,
      [
        // Treating the committee as ordered is the standard slip.
        '${_permutations(n, r)}',
        '${_combinations(n, r - 1)}',
        '${_combinations(n + 1, r)}',
        '${n * r}',
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'A committee of $r members is to be formed from a group of $n '
          'people. In how many different ways can this be done?',
      solution: 'Order does not matter in a committee, so this is a '
          'combination: C($n, $r) = $n!/($r! × ${n - r}!) = $ways. '
          'If the roles were distinct it would instead be P($n, $r) = '
          '${_permutations(n, r)}.',
      options: built.options,
      answerIndex: built.index,
      answer: ways.toDouble(),
      crossCheck: cross,
      verifyExpr: 'combinations($n,$r)',
    );
  }
}

/// Two draws without replacement.
class ProbabilityTemplate extends CatTemplate {
  const ProbabilityTemplate();

  @override
  String get topic => 'Probability';
  @override
  String get difficulty => 'Hard';

  @override
  GeneratedQuestion? generate(Random rng) {
    final red = _pick(rng, [4, 5, 6, 7]);
    final blue = _pick(rng, [3, 4, 5, 6]);
    final total = red + blue;

    // Primary: count favourable pairs over total pairs.
    final favourable = _combinations(red, 2);
    final possible = _combinations(total, 2);
    final answer = favourable / possible;

    // Independent route: multiply the two sequential draw probabilities.
    final cross = (red / total) * ((red - 1) / (total - 1));

    final correct = Num.fraction(favourable, possible);
    final built = _options(
      correct,
      [
        // Forgetting that the first ball is not replaced.
        Num.fraction(red * red, total * total),
        Num.fraction(_combinations(blue, 2), possible),
        Num.fraction(red, total),
        Num.fraction(favourable + 1, possible),
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'A bag contains $red red balls and $blue blue balls. Two balls are '
          'drawn at random, one after the other, without replacement. What is '
          'the probability that both are red?',
      solution: 'Favourable pairs = C($red, 2) = $favourable. '
          'Total pairs = C($total, 2) = $possible. '
          'Probability = $favourable/$possible = $correct. '
          'Equivalently $red/$total × ${red - 1}/${total - 1} — the second '
          'draw has one fewer red and one fewer ball.',
      options: built.options,
      answerIndex: built.index,
      answer: answer,
      crossCheck: cross,
      verifyExpr: 'combinations($red,2)/combinations($total,2)',
    );
  }
}

/// A new member shifts the average — solve for the original count.
class AverageChangeTemplate extends CatTemplate {
  const AverageChangeTemplate();

  @override
  String get topic => 'Averages';
  @override
  String get difficulty => 'Medium';

  @override
  GeneratedQuestion? generate(Random rng) {
    final count = _pick(rng, [8, 10, 12, 15, 20, 24]);
    final oldAverage = _pick(rng, [40, 45, 50, 55, 60]);
    final shift = _pick(rng, [1, 2]);
    final newAverage = oldAverage + shift;

    // Construct the newcomer's weight so the answer is exactly `count`.
    final weight = newAverage + count * shift;

    final answer = (weight - newAverage) / (newAverage - oldAverage);

    // Independent route: substitute the answer back into the original
    // condition rather than re-deriving it.
    final totalBefore = answer * oldAverage;
    final resulting = (totalBefore + weight) / (answer + 1);
    final cross = Num.agree(resulting, newAverage.toDouble())
        ? answer
        : double.nan;

    final correct = Num.format(answer);
    final built = _options(
      correct,
      [
        Num.format(answer + 1),
        Num.format(answer - 1),
        Num.format((weight - oldAverage) / shift),
        Num.format(answer + 2),
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'The average weight of a group of students is $oldAverage kg. When '
          'a new student weighing $weight kg joins the group, the average '
          'rises to $newAverage kg. How many students were there originally?',
      solution: 'Let there be n students. Then '
          '(n × $oldAverage + $weight)/(n + 1) = $newAverage. '
          'So n × $oldAverage + $weight = n × $newAverage + $newAverage, '
          'giving n × $shift = ${weight - newAverage} and n = '
          '${Num.format(answer)}. '
          'Sanity check: ${Num.format(answer)} × $oldAverage + $weight = '
          '${Num.format(totalBefore + weight)}, divided by '
          '${Num.format(answer + 1)} gives $newAverage.',
      options: built.options,
      answerIndex: built.index,
      answer: answer,
      crossCheck: cross,
      verifyExpr: '($weight - $newAverage)/($newAverage - $oldAverage)',
    );
  }
}

/// Dilute a mixture to a target ratio.
class MixtureTemplate extends CatTemplate {
  const MixtureTemplate();

  @override
  String get topic => 'Ratio & Mixtures';
  @override
  String get difficulty => 'Medium';

  @override
  GeneratedQuestion? generate(Random rng) {
    final volume = _pick(rng, [60, 72, 90, 120, 150]);
    final milkPart = _pick(rng, [2, 3, 4, 5]);
    final waterPart = _pick(rng, [1, 2, 3]);
    final parts = milkPart + waterPart;
    if (volume % parts != 0) return null;

    final milk = volume * milkPart / parts;
    final water = volume * waterPart / parts;

    final targetMilk = _pick(rng, [1, 2, 3]);
    final targetWater = _pick(rng, [1, 2, 3]);

    // Only dilution — adding water can't raise the milk share.
    if (targetMilk / targetWater >= milkPart / waterPart) return null;

    final added = milk * targetWater / targetMilk - water;
    if (added <= 0) return null;
    if ((added - added.roundToDouble()).abs() > 1e-9) return null;

    // Independent route: check the resulting ratio actually lands on target.
    final resulting = milk / (water + added);
    final cross = Num.agree(resulting, targetMilk / targetWater)
        ? added
        : double.nan;

    final correct = '${Num.format(added)} litres';
    final built = _options(
      correct,
      [
        '${Num.format(added + 5)} litres',
        '${Num.format(water)} litres',
        '${Num.format(milk - water)} litres',
        '${Num.format(added * 2)} litres',
      ],
      rng,
    );
    if (built == null) return null;

    return GeneratedQuestion(
      topic: topic,
      difficulty: difficulty,
      stem: 'A vessel contains $volume litres of a mixture of milk and water '
          'in the ratio $milkPart : $waterPart. How many litres of water must '
          'be added so that the ratio of milk to water becomes '
          '$targetMilk : $targetWater?',
      solution: 'Milk = $volume × $milkPart/$parts = ${Num.format(milk)} L and '
          'water = ${Num.format(water)} L. '
          'The milk is unchanged, so for a $targetMilk : $targetWater ratio the '
          'water must become ${Num.format(milk)} × $targetWater/$targetMilk = '
          '${Num.format(water + added)} L. '
          'Water to add = ${Num.format(water + added)} − ${Num.format(water)} = '
          '${Num.format(added)} litres.',
      options: built.options,
      answerIndex: built.index,
      answer: added,
      crossCheck: cross,
      verifyExpr:
          '($volume*$milkPart/$parts)*$targetWater/$targetMilk - $volume*$waterPart/$parts',
    );
  }
}

/// Every template the generator draws from.
const catTemplates = <CatTemplate>[
  ProfitLossTemplate(),
  TimeAndWorkTemplate(),
  AverageSpeedTemplate(),
  SuccessiveChangeTemplate(),
  TrailingZerosTemplate(),
  CombinationsTemplate(),
  ProbabilityTemplate(),
  AverageChangeTemplate(),
  MixtureTemplate(),
];
