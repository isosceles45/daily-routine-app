import 'package:daily_ritual/features/home/domain/daily_completion.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityStatus status(DailyActivity a, {bool done = false, bool avail = true}) =>
    ActivityStatus(activity: a, completed: done, available: avail);

void main() {
  group('scoring', () {
    test('counts only the activities that exist', () {
      // An unbuilt feature is not something the user skipped.
      final c = DailyCompletion([
        status(DailyActivity.trivia, done: true),
        status(DailyActivity.wordle),
        status(DailyActivity.surprise, avail: false),
      ]);

      expect(c.completed, 1);
      expect(c.total, 2);
    });

    test('an empty day scores zero of zero', () {
      expect(DailyCompletion.empty.total, 0);
      expect(DailyCompletion.empty.completed, 0);
      expect(DailyCompletion.empty.isComplete, isFalse,
          reason: 'nothing to do is not the same as everything done');
    });
  });

  group('remaining', () {
    test('names exactly what is outstanding', () {
      final c = DailyCompletion([
        status(DailyActivity.wordle, done: true),
        status(DailyActivity.catQuant, done: true),
        status(DailyActivity.trivia),
        status(DailyActivity.challenge),
      ]);

      expect(c.remaining, [DailyActivity.trivia, DailyActivity.challenge]);
    });

    test('keeps the order shown on Today', () {
      // The list is read against the page, so it must not reorder.
      final c = DailyCompletion([
        status(DailyActivity.wordle),
        status(DailyActivity.catQuant),
        status(DailyActivity.trivia),
      ]);
      expect(c.remaining,
          [DailyActivity.wordle, DailyActivity.catQuant, DailyActivity.trivia]);
    });

    test('excludes unavailable activities', () {
      final c = DailyCompletion([
        status(DailyActivity.trivia, done: true),
        status(DailyActivity.surprise, avail: false),
      ]);
      expect(c.remaining, isEmpty);
      expect(c.isComplete, isTrue);
    });

    test('is empty exactly when the day is complete', () {
      final done = DailyCompletion([
        status(DailyActivity.trivia, done: true),
        status(DailyActivity.wordle, done: true),
      ]);
      expect(done.remaining, isEmpty);
      expect(done.isComplete, isTrue);

      final partial = DailyCompletion([
        status(DailyActivity.trivia, done: true),
        status(DailyActivity.wordle),
      ]);
      expect(partial.remaining, hasLength(1));
      expect(partial.isComplete, isFalse);
    });

    test('remaining count always agrees with the score', () {
      final c = DailyCompletion([
        status(DailyActivity.wordle, done: true),
        status(DailyActivity.catQuant),
        status(DailyActivity.trivia),
        status(DailyActivity.fun, avail: false),
      ]);
      expect(c.remaining.length, c.total - c.completed);
    });
  });

  test('every activity has a label to show in the chip', () {
    for (final activity in DailyActivity.values) {
      expect(activity.label.trim(), isNotEmpty);
    }
  });
}
