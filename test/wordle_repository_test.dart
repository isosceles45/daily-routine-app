import 'package:daily_ritual/app/router.dart';
import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/features/wordle/data/wordle_repository.dart';
import 'package:daily_ritual/features/wordle/domain/wordle_share.dart';
import 'package:daily_ritual/features/wordle/providers/wordle_providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const share = '''Wordle 1,234 4/6

⬛⬛🟨⬛⬛
⬛🟨⬛⬛🟨
🟨🟩⬛⬛⬛
🟩🟩🟩🟩🟩''';

void main() {
  late AppDatabase db;
  late WordleRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = WordleRepository(db);
  });

  tearDown(() async => db.close());

  test('saves a parsed share under the puzzle’s own date', () async {
    final parsed = WordleShareParser.parse(share)!;
    await repository.save(parsed);

    final stored = await repository.forDate(parsed.date);
    expect(stored, isNotNull);
    expect(stored!.wordleNumber, 1234);
    expect(stored.score, 4);
    expect(stored.completed, isTrue);
    expect(stored.grid!.split('\n'), hasLength(4));
  });

  test('re-importing the same day overwrites rather than duplicating', () async {
    await repository.save(WordleShareParser.parse('Wordle 1234 5/6')!);
    await repository.save(WordleShareParser.parse('Wordle 1234 3/6')!);

    final all = await repository.all();
    expect(all, hasLength(1), reason: 'pasting twice must not inflate stats');
    expect(all.single.score, 3);
  });

  test('stores a failure without a score', () async {
    await repository.save(WordleShareParser.parse('Wordle 1234 X/6')!);
    final stored = await repository.forDate(WordleShareParser.dateFor(1234));
    expect(stored!.completed, isFalse);
    expect(stored.score, isNull);
  });

  test('records hard mode', () async {
    await repository.save(WordleShareParser.parse('Wordle 1234 4/6*')!);
    final stored = await repository.forDate(WordleShareParser.dateFor(1234));
    expect(stored!.hardMode, isTrue);
  });

  test('a share with no grid stores null rather than an empty string', () async {
    await repository.save(WordleShareParser.parse('Wordle 1234 4/6')!);
    final stored = await repository.forDate(WordleShareParser.dateFor(1234));
    expect(stored!.grid, isNull);
  });

  test('different puzzles land on different days', () async {
    await repository.save(WordleShareParser.parse('Wordle 1234 4/6')!);
    await repository.save(WordleShareParser.parse('Wordle 1235 2/6')!);

    final all = await repository.all();
    expect(all, hasLength(2));
    // Newest first.
    expect(all.first.wordleNumber, 1235);
  });

  test('removing clears the day', () async {
    final parsed = WordleShareParser.parse(share)!;
    await repository.save(parsed);
    await repository.remove(parsed.date);
    expect(await repository.forDate(parsed.date), isNull);
  });

  group('repairMisfiledDates', () {
    Future<void> insertAt(String date, int number) async {
      await db.into(db.wordleResults).insert(
            WordleResultsCompanion.insert(
              date: date,
              wordleNumber: number,
              score: const Value(4),
              completed: const Value(true),
              grid: const Value('🟩🟩🟩🟩🟩'),
              importedAt: DateTime(2026, 8, 28),
            ),
          );
    }

    test('moves a row filed one day early', () async {
      // Exactly the shape the off-by-one epoch produced.
      await insertAt('2026-08-27', 1896);

      expect(await repository.repairMisfiledDates(), 1);

      expect(await repository.forDate('2026-08-27'), isNull);
      final fixed = await repository.forDate('2026-08-28');
      expect(fixed, isNotNull);
      expect(fixed!.wordleNumber, 1896);
      expect(fixed.score, 4, reason: 'the result itself must survive the move');
      expect(fixed.grid, '🟩🟩🟩🟩🟩');
    });

    test('leaves correctly filed rows alone', () async {
      await insertAt('2026-08-28', 1896);
      expect(await repository.repairMisfiledDates(), 0);
      expect(await repository.forDate('2026-08-28'), isNotNull);
    });

    test('is safe to run twice', () async {
      await insertAt('2026-08-27', 1896);
      await repository.repairMisfiledDates();
      expect(await repository.repairMisfiledDates(), 0);
      expect(await repository.all(), hasLength(1));
    });

    test('repairs several rows without collapsing them', () async {
      await insertAt('2026-08-25', 1894);
      await insertAt('2026-08-26', 1895);
      await insertAt('2026-08-27', 1896);

      expect(await repository.repairMisfiledDates(), 3);

      final all = await repository.all();
      expect(all, hasLength(3), reason: 'shifting must not overwrite neighbours');
      expect(all.map((r) => r.date).toSet(),
          {'2026-08-26', '2026-08-27', '2026-08-28'});
    });
  });

  group('wordleRouteFor', () {
    test('an unplayed day opens Wordle directly', () {
      // Every entry point on Today says "play", so none of them may land on
      // another screen that also says "play".
      expect(wordleRouteFor(null), Routes.wordlePlay);
      expect(Routes.wordlePlay, contains('play=1'));
    });

    test('once imported it opens the result instead', () async {
      await repository.save(WordleShareParser.parse('Wordle 1896 4/6')!);
      final today = await repository.forDate('2026-08-28');

      expect(wordleRouteFor(today), Routes.wordle);
      expect(Routes.wordle, isNot(contains('play=1')),
          reason: 'there is nothing left to play once a result exists');
    });
  });
}
