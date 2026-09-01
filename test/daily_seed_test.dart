import 'package:daily_ritual/core/utils/daily_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the same date and type always give the same seed', () {
    expect(
      dailySeed('2026-08-26', 'pokemon'),
      dailySeed('2026-08-26', 'pokemon'),
    );
  });

  test('different content types decorrelate', () {
    // The whole point of hashing "date:type" rather than the bare date: if
    // these matched, every section would move in lockstep.
    expect(
      dailySeed('2026-08-26', 'pokemon'),
      isNot(dailySeed('2026-08-26', 'trivia-category')),
    );
  });

  test('consecutive days produce different seeds', () {
    expect(
      dailySeed('2026-08-26', 'pokemon'),
      isNot(dailySeed('2026-08-27', 'pokemon')),
    );
  });

  test('stays inside 32 bits', () {
    for (final day in ['2026-01-01', '2026-08-26', '2027-12-31']) {
      final seed = dailySeed(day, 'anything');
      expect(seed, greaterThanOrEqualTo(0));
      expect(seed, lessThanOrEqualTo(0xFFFFFFFF));
    }
  });

  test('is pinned to known values so past days never reshuffle', () {
    // Hard-coded on purpose. If the hash ever changes, every previously shown
    // Pokémon and joke silently changes with it — this test is the tripwire.
    expect(dailySeed('2026-08-26', 'pokemon'), 2218812826);
    expect(dailySeed('2026-01-01', 'trivia-category'), 704543623);
  });

  test('dailyIndex stays in range and dailyPick is stable', () {
    for (var d = 1; d <= 28; d++) {
      final date = '2026-02-${d.toString().padLeft(2, '0')}';
      expect(dailyIndex(date, 'pokemon', 1025), inInclusiveRange(0, 1024));
    }

    const items = ['a', 'b', 'c'];
    expect(
      dailyPick('2026-08-26', 'fun-kind', items),
      dailyPick('2026-08-26', 'fun-kind', items),
    );
  });

  test('dailyIndex rejects an empty range', () {
    expect(() => dailyIndex('2026-08-26', 'x', 0), throwsArgumentError);
  });
}
