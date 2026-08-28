import '../../../core/utils/daily_seed.dart';

/// One OpenTDB question, plus the deterministic answer ordering for the day.
class TriviaQuestion {
  const TriviaQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.answers,
    required this.source,
  });

  final String id;
  final String category;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  /// All options in a stable, shuffled order. Reshuffling on every rebuild
  /// would make the answers hop around under the user's finger.
  final List<String> answers;

  final String source;

  bool isCorrect(String answer) => answer == correctAnswer;

  /// OpenTDB has no question id, so derive a stable one from the text. Used to
  /// tie a saved result back to the question it was answering.
  static String idFor(String question) =>
      dailySeed(question, 'trivia-id').toRadixString(16);

  /// Builds from an OpenTDB result. Requests use `encode=url3986`, so every
  /// string arrives percent-encoded and must be decoded before display.
  factory TriviaQuestion.fromOpenTdb(
    Map<String, dynamic> json, {
    required String date,
  }) {
    String decode(Object? value) => Uri.decodeComponent('${value ?? ''}');

    final question = decode(json['question']);
    final correct = decode(json['correct_answer']);
    final incorrect = (json['incorrect_answers'] as List<dynamic>? ?? [])
        .map(decode)
        .toList(growable: false);

    if (question.isEmpty || correct.isEmpty || incorrect.isEmpty) {
      throw const FormatException('OpenTDB result was missing fields');
    }

    return TriviaQuestion(
      id: idFor(question),
      category: decode(json['category']),
      difficulty: decode(json['difficulty']),
      question: question,
      correctAnswer: correct,
      incorrectAnswers: incorrect,
      answers: _orderAnswers([correct, ...incorrect], date),
      source: 'OpenTDB',
    );
  }

  static List<String> _orderAnswers(List<String> all, String date) {
    final ordered = [...all];
    ordered.shuffle(dailyRandom(date, 'trivia-answers'));
    return List.unmodifiable(ordered);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'difficulty': difficulty,
        'question': question,
        'correctAnswer': correctAnswer,
        'incorrectAnswers': incorrectAnswers,
        'answers': answers,
        'source': source,
      };

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) => TriviaQuestion(
        id: json['id'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        question: json['question'] as String,
        correctAnswer: json['correctAnswer'] as String,
        incorrectAnswers:
            (json['incorrectAnswers'] as List<dynamic>).cast<String>(),
        answers: List.unmodifiable(
            (json['answers'] as List<dynamic>).cast<String>()),
        source: json['source'] as String? ?? 'OpenTDB',
      );
}

/// The categories the app draws from (§7), as OpenTDB ids.
class TriviaCategory {
  const TriviaCategory(this.id, this.label);
  final int id;
  final String label;

  static const all = [
    TriviaCategory(9, 'General Knowledge'),
    TriviaCategory(17, 'Science & Nature'),
    TriviaCategory(18, 'Computers'),
    TriviaCategory(22, 'Geography'),
    TriviaCategory(23, 'History'),
    TriviaCategory(21, 'Sports'),
    TriviaCategory(27, 'Animals'),
    TriviaCategory(11, 'Film'),
    TriviaCategory(12, 'Music'),
    TriviaCategory(20, 'Mythology'),
    TriviaCategory(25, 'Art'),
  ];

  /// Same date always yields the same category (§22).
  static TriviaCategory forDate(String date) =>
      dailyPick(date, 'trivia-category', all);
}
