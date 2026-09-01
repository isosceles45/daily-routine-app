import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/features/events/domain/countdown.dart';
import 'package:flutter_test/flutter_test.dart';

Countdown on(
  String eventDate, {
  String today = '2026-09-01',
  bool pinned = false,
}) {
  return Countdown(
    event: Event(
      id: 'e',
      title: 'Uttarakhand trip',
      date: eventDate,
      pinned: pinned,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
    today: today,
  );
}

void main() {
  group('days', () {
    test('counts whole calendar days ahead', () {
      expect(on('2026-09-13').days, 12);
    });

    test('is zero on the day itself', () {
      expect(on('2026-09-01').days, 0);
      expect(on('2026-09-01').isToday, isTrue);
    });

    test('goes negative once it has passed', () {
      expect(on('2026-08-30').days, -2);
      expect(on('2026-08-30').isPast, isTrue);
    });

    test('crosses a month boundary correctly', () {
      expect(on('2026-10-01').days, 30);
    });

    test('crosses a year boundary correctly', () {
      expect(on('2027-01-01', today: '2026-12-25').days, 7);
    });

    test('handles a leap day without drifting', () {
      expect(on('2028-03-01', today: '2028-02-28').days, 2);
    });
  });

  group('headline', () {
    test('reads naturally at the boundaries', () {
      expect(on('2026-09-01').headline, 'Today');
      expect(on('2026-09-02').headline, 'Tomorrow');
      expect(on('2026-08-31').headline, 'Yesterday');
      expect(on('2026-09-13').headline, '12 days');
      expect(on('2026-08-25').headline, '7 days ago');
    });
  });

  group('weeksHint', () {
    test('is absent for anything under a fortnight', () {
      expect(on('2026-09-13').weeksHint, isNull);
    });

    test('rounds long waits into weeks', () {
      expect(on('2026-09-15').weeksHint, 'about 2 weeks');
      expect(on('2026-09-18').weeksHint, 'about 2 weeks and 3 days');
      expect(on('2026-09-16').weeksHint, 'about 2 weeks and 1 day');
    });
  });

  group('ordering', () {
    test('upcoming lead, soonest first; past sink to the bottom', () {
      final list = [
        on('2026-08-20'),
        on('2026-12-25'),
        on('2026-09-05'),
        on('2026-08-31'),
      ]..sort(Countdown.compare);

      expect(
        list.map((c) => c.date).toList(),
        // Soonest ahead, then the rest ahead, then most-recent past first.
        ['2026-09-05', '2026-12-25', '2026-08-31', '2026-08-20'],
      );
    });

    test('a pinned event leads the upcoming group', () {
      final list = [on('2026-09-05'), on('2026-12-25', pinned: true)]
        ..sort(Countdown.compare);

      expect(list.first.date, '2026-12-25');
    });
  });
}
