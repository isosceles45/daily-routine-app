import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/features/wordle/data/wordle_repository.dart';
import 'package:daily_ritual/features/wordle/domain/wordle_share.dart';
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
}
