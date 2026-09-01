import 'package:daily_ritual/core/database/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  group('daily state', () {
    test('creates a day once and returns the same row after', () async {
      final first = await db.ensureDay('2026-08-26');
      final second = await db.ensureDay('2026-08-26');

      expect(second.date, first.date);
      expect(
        second.createdAt,
        first.createdAt,
        reason: 'reopening the app must not reset the day',
      );
      expect(await db.select(db.dailyStates).get(), hasLength(1));
    });

    test('a new date creates a separate day', () async {
      await db.ensureDay('2026-08-26');
      await db.ensureDay('2026-08-27');
      expect(await db.select(db.dailyStates).get(), hasLength(2));
    });

    test('greeting is unshown until marked, then stays marked', () async {
      final day = await db.ensureDay('2026-08-26');
      expect(day.greetingShown, isFalse);

      await db.markGreetingShown('2026-08-26');
      final updated = await db.ensureDay('2026-08-26');
      expect(updated.greetingShown, isTrue);
    });
  });

  group('daily content cache', () {
    test('a miss returns null', () async {
      expect(await db.readContent('2026-08-26', 'trivia'), isNull);
    });

    test('round-trips a payload', () async {
      await db.writeContent(
        date: '2026-08-26',
        contentType: 'trivia',
        source: 'OpenTDB',
        sourceId: 'abc',
        payload: {
          'question': 'Why?',
          'answers': ['a', 'b'],
        },
      );

      final cached = await db.readContent('2026-08-26', 'trivia');
      expect(cached, isNotNull);
      expect(cached!['question'], 'Why?');
      expect(cached['answers'], ['a', 'b']);
    });

    test(
      'writing again for the same day replaces rather than duplicates',
      () async {
        for (final q in ['first', 'second']) {
          await db.writeContent(
            date: '2026-08-26',
            contentType: 'trivia',
            source: 'OpenTDB',
            payload: {'question': q},
          );
        }

        expect(await db.select(db.dailyContents).get(), hasLength(1));
        expect(
          (await db.readContent('2026-08-26', 'trivia'))!['question'],
          'second',
        );
      },
    );

    test('content types and dates are independent keys', () async {
      await db.writeContent(
        date: '2026-08-26',
        contentType: 'trivia',
        source: 'x',
        payload: {'v': 1},
      );
      await db.writeContent(
        date: '2026-08-26',
        contentType: 'pokemon',
        source: 'x',
        payload: {'v': 2},
      );
      await db.writeContent(
        date: '2026-08-27',
        contentType: 'trivia',
        source: 'x',
        payload: {'v': 3},
      );

      expect((await db.readContent('2026-08-26', 'trivia'))!['v'], 1);
      expect((await db.readContent('2026-08-26', 'pokemon'))!['v'], 2);
      expect((await db.readContent('2026-08-27', 'trivia'))!['v'], 3);
    });

    test('a corrupt row is dropped instead of crashing the caller', () async {
      // Simulates a partial write or a payload from an incompatible build.
      await db
          .into(db.dailyContents)
          .insert(
            DailyContentsCompanion.insert(
              date: '2026-08-26',
              contentType: 'trivia',
              source: 'OpenTDB',
              sourceId: const Value(null),
              payload: '{not valid json',
              createdAt: DateTime.now(),
            ),
          );

      expect(await db.readContent('2026-08-26', 'trivia'), isNull);
      expect(
        await db.select(db.dailyContents).get(),
        isEmpty,
        reason: 'the bad row must be cleared so the next fetch can cache',
      );
    });

    test('deleting a cache entry forces a refetch', () async {
      await db.writeContent(
        date: '2026-08-26',
        contentType: 'trivia',
        source: 'x',
        payload: {'v': 1},
      );
      await db.deleteContent('2026-08-26', 'trivia');
      expect(await db.readContent('2026-08-26', 'trivia'), isNull);
    });
  });

  group('settings', () {
    test('returns null for an unset key', () async {
      expect(await db.getSetting('opentdb_token'), isNull);
    });

    test('stores and overwrites', () async {
      await db.setSetting('opentdb_token', 'first');
      expect(await db.getSetting('opentdb_token'), 'first');

      await db.setSetting('opentdb_token', 'second');
      expect(await db.getSetting('opentdb_token'), 'second');
      expect(await db.select(db.appSettings).get(), hasLength(1));
    });
  });
}
