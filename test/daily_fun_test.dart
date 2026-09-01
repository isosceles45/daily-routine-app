import 'package:daily_ritual/features/animals/domain/daily_fun.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weekday rotation (§9)', () {
    test('the non-animal days keep their fixed flavour', () {
      // 2026-08-24 is a Monday.
      expect(FunKind.forDate('2026-08-25'), FunKind.joke);
      expect(FunKind.forDate('2026-08-27'), FunKind.weirdFact);
      expect(FunKind.forDate('2026-08-29'), FunKind.darkJoke);
    });

    test('Monday, Wednesday and Friday are always an animal', () {
      for (final date in ['2026-08-24', '2026-08-26', '2026-08-28']) {
        expect(FunKind.forDate(date).isAnimal, isTrue, reason: date);
      }
    });

    test('the animal days are not just cats and dogs', () {
      // The whole point of the menagerie: across a couple of months of animal
      // days, more than two species have to actually show up.
      final seen = <FunKind>{};
      for (var day = 1; day <= 60; day++) {
        final date = '2026-09-${day.toString().padLeft(2, '0')}';
        if (day > 30) continue;
        final kind = FunKind.forDate(date);
        if (kind.isAnimal) seen.add(kind);
      }
      expect(seen.length, greaterThan(2));
      expect(seen.every((k) => FunKind.animals.contains(k)), isTrue);
    });

    test('Sunday is a free pick, but a stable one', () {
      const sunday = '2026-08-30';
      expect(FunKind.forDate(sunday), FunKind.forDate(sunday));
    });

    test('a given date always resolves the same way', () {
      expect(FunKind.forDate('2026-08-24'), FunKind.forDate('2026-08-24'));
      expect(FunKind.forDate('2026-08-31'), FunKind.forDate('2026-08-31'));
    });
  });

  group('DailyFun', () {
    test('an image alone still counts as content', () {
      const fun = DailyFun(
        kind: FunKind.cat,
        source: 'Cataas',
        imageUrl: 'https://x/y.jpg',
      );
      expect(fun.hasContent, isTrue);
    });

    test('text alone still counts as content', () {
      const fun = DailyFun(kind: FunKind.joke, source: 'JokeAPI', text: 'Ha.');
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
