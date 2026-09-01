import 'package:daily_ritual/features/trivia/domain/trivia_question.dart';
import 'package:flutter_test/flutter_test.dart';

/// A real OpenTDB payload shape, percent-encoded as `encode=url3986` returns it.
Map<String, dynamic> openTdbResult({
  String question = 'Which%20planet%20has%20the%20most%20moons%3F',
  String correct = 'Saturn',
}) => {
  'type': 'multiple',
  'difficulty': 'easy',
  'category': 'Science%20%26%20Nature',
  'question': question,
  'correct_answer': correct,
  'incorrect_answers': ['Jupiter', 'Uranus', 'Neptune'],
};

void main() {
  const date = '2026-08-26';

  test('decodes percent-encoded text', () {
    final q = TriviaQuestion.fromOpenTdb(openTdbResult(), date: date);
    expect(q.question, 'Which planet has the most moons?');
    expect(q.category, 'Science & Nature');
  });

  test('keeps every option exactly once', () {
    final q = TriviaQuestion.fromOpenTdb(openTdbResult(), date: date);
    expect(q.answers, hasLength(4));
    expect(q.answers.toSet(), hasLength(4));
    expect(q.answers, contains('Saturn'));
    expect(q.answers, containsAll(['Jupiter', 'Uranus', 'Neptune']));
  });

  test('answer order is stable for a date but differs across dates', () {
    final a = TriviaQuestion.fromOpenTdb(openTdbResult(), date: date);
    final b = TriviaQuestion.fromOpenTdb(openTdbResult(), date: date);
    expect(
      a.answers,
      b.answers,
      reason: 'options must not hop around between rebuilds',
    );

    // Not a guarantee for any single pair of dates, but across a month at
    // least one ordering must differ or the shuffle is not seeded at all.
    final orderings = <String>{};
    for (var d = 1; d <= 28; d++) {
      final day = '2026-09-${d.toString().padLeft(2, '0')}';
      orderings.add(
        TriviaQuestion.fromOpenTdb(
          openTdbResult(),
          date: day,
        ).answers.join('|'),
      );
    }
    expect(orderings.length, greaterThan(1));
  });

  test('scores answers', () {
    final q = TriviaQuestion.fromOpenTdb(openTdbResult(), date: date);
    expect(q.isCorrect('Saturn'), isTrue);
    expect(q.isCorrect('Jupiter'), isFalse);
  });

  test('rejects a result missing its fields', () {
    expect(
      () => TriviaQuestion.fromOpenTdb(openTdbResult(question: ''), date: date),
      throwsFormatException,
    );
    expect(
      () => TriviaQuestion.fromOpenTdb({
        ...openTdbResult(),
        'incorrect_answers': <String>[],
      }, date: date),
      throwsFormatException,
    );
  });

  test('survives a cache round-trip', () {
    final original = TriviaQuestion.fromOpenTdb(openTdbResult(), date: date);
    final restored = TriviaQuestion.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.question, original.question);
    expect(restored.correctAnswer, original.correctAnswer);
    expect(
      restored.answers,
      original.answers,
      reason: 'a replayed question must present its options identically',
    );
  });

  test('derives a stable id from the question text', () {
    expect(
      TriviaQuestion.idFor('Same text'),
      TriviaQuestion.idFor('Same text'),
    );
    expect(TriviaQuestion.idFor('A'), isNot(TriviaQuestion.idFor('B')));
  });

  test('picks the same category for a given date', () {
    expect(TriviaCategory.forDate(date).id, TriviaCategory.forDate(date).id);
  });
}
