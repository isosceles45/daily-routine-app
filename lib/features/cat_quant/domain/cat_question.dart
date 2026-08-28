import '../../../core/utils/daily_seed.dart';

/// Where a question came from. Shown to the user as a source badge, because
/// "generated" and "fetched" deserve different trust and different credit.
enum CatSource {
  openTdb('OpenTDB'),
  remoteBank('Question bank'),
  generated('Generated');

  const CatSource(this.label);
  final String label;
}

/// How the answer was checked before it was allowed on screen (§8).
enum CatVerification {
  /// Confirmed against api.mathjs.org.
  mathJs('Verified via math.js'),

  /// Confirmed offline by deriving the answer a second, independent way.
  crossChecked('Verified offline'),

  /// The source published the answer itself and it is not ours to re-derive.
  sourceProvided('From source');

  const CatVerification(this.label);
  final String label;
}

/// A CAT-level quantitative question with four options.
class CatQuestion {
  const CatQuestion({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.stem,
    required this.options,
    required this.answerIndex,
    required this.source,
    required this.verification,
    this.solution,
  });

  final String id;
  final String topic;

  /// "Medium" or "Hard" — the target band is CAT Quant, not school arithmetic.
  final String difficulty;

  final String stem;
  final List<String> options;
  final int answerIndex;

  /// The worked solution, shown after answering. Null only when the source
  /// gave none — never fabricated.
  final String? solution;

  final CatSource source;
  final CatVerification verification;

  bool isCorrect(int index) => index == answerIndex;

  static String letterFor(int index) => const ['A', 'B', 'C', 'D'][index];

  static String idFor(String stem) =>
      dailySeed(stem, 'cat-id').toRadixString(16);

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'difficulty': difficulty,
        'stem': stem,
        'options': options,
        'answerIndex': answerIndex,
        'solution': solution,
        'source': source.name,
        'verification': verification.name,
      };

  factory CatQuestion.fromJson(Map<String, dynamic> json) => CatQuestion(
        id: json['id'] as String,
        topic: json['topic'] as String,
        difficulty: json['difficulty'] as String,
        stem: json['stem'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        answerIndex: json['answerIndex'] as int,
        solution: json['solution'] as String?,
        source: CatSource.values.firstWhere(
          (s) => s.name == json['source'],
          orElse: () => CatSource.generated,
        ),
        verification: CatVerification.values.firstWhere(
          (v) => v.name == json['verification'],
          orElse: () => CatVerification.crossChecked,
        ),
      );
}

/// Number formatting shared by the generator templates.
abstract final class Num {
  /// Trims a trailing `.0` so answers read as "12" rather than "12.0", but
  /// keeps genuine decimals.
  static String format(double value) {
    if ((value - value.roundToDouble()).abs() < 1e-9) {
      return value.round().toString();
    }
    final oneDp = value.toStringAsFixed(1);
    if ((double.parse(oneDp) - value).abs() < 1e-9) return oneDp;
    return value.toStringAsFixed(2);
  }

  static String percent(double value) => '${format(value)}%';

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a == 0 ? 1 : a;
  }

  /// Renders `n/d` in lowest terms.
  static String fraction(int numerator, int denominator) {
    final g = gcd(numerator, denominator);
    final n = numerator ~/ g;
    final d = denominator ~/ g;
    return d == 1 ? '$n' : '$n/$d';
  }

  /// Whether two derivations agree closely enough to trust.
  static bool agree(double a, double b) {
    final scale = a.abs() > 1 ? a.abs() : 1.0;
    return (a - b).abs() / scale < 1e-6;
  }
}
