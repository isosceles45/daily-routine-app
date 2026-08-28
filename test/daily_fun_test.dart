import 'package:daily_ritual/features/animals/domain/daily_fun.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weekday rotation (§9)', () {
    test('follows the published schedule', () {
      // 2026-08-24 is a Monday.
      expect(FunKind.forDate('2026-08-24'), FunKind.cat);
      expect(FunKind.forDate('2026-08-25'), FunKind.joke);
      expect(FunKind.forDate('2026-08-26'), FunKind.dog);
      expect(FunKind.forDate('2026-08-27'), FunKind.weirdFact);
      expect(FunKind.forDate('2026-08-28'), FunKind.cat);
      expect(FunKind.forDate('2026-08-29'), FunKind.darkJoke);
    });

    test('Sunday is a free pick, but a stable one', () {
      const sunday = '2026-08-30';
      expect(FunKind.forDate(sunday), FunKind.forDate(sunday));
    });

    test('the same weekday resolves the same way in a later week', () {
      expect(FunKind.forDate('2026-08-24'), FunKind.forDate('2026-08-31'));
    });
  });

  group('DailyFun', () {
    test('an image alone still counts as content', () {
      const fun = DailyFun(
          kind: FunKind.cat, source: 'Cataas', imageUrl: 'https://x/y.jpg');
      expect(fun.hasContent, isTrue);
    });

    test('text alone still counts as content', () {
      const fun =
          DailyFun(kind: FunKind.joke, source: 'JokeAPI', text: 'Ha.');
      expect(fun.hasContent, isTrue);
    });

    test('neither means no content', () {
      const fun = DailyFun(kind: FunKind.dog, source: 'dog.ceo');
      expect(fun.hasContent, isFalse);
    });

    test('survives a cache round-trip', () {
      const original = DailyFun(
        kind: FunKind.darkJoke,
        source: 'JokeAPI',
        text: 'A joke.',
        imageUrl: null,
      );
      final restored = DailyFun.fromJson(original.toJson());
      expect(restored.kind, FunKind.darkJoke);
      expect(restored.text, 'A joke.');
      expect(restored.imageUrl, isNull);
    });

    test('an unknown kind degrades instead of throwing', () {
      // Guards against a cached row written by a future version.
      final restored = DailyFun.fromJson({'kind': 'unicorn', 'source': 'x'});
      expect(restored.kind, FunKind.weirdFact);
    });
  });
}
