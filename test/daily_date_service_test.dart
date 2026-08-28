import 'package:daily_ritual/core/dates/daily_date_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('format/parse', () {
    test('pads month and day to yyyy-MM-dd', () {
      expect(DailyDateService.format(DateTime(2026, 1, 5)), '2026-01-05');
      expect(DailyDateService.format(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('round-trips', () {
      const date = '2026-08-26';
      expect(DailyDateService.format(DailyDateService.parse(date)), date);
    });

    test('rejects malformed input', () {
      expect(() => DailyDateService.parse('26-08-2026'), throwsFormatException);
      expect(() => DailyDateService.parse('nonsense'), throwsFormatException);
      expect(() => DailyDateService.parse('2026-8-26'), throwsFormatException);
      expect(() => DailyDateService.parse(''), throwsFormatException);
    });

    test('rejects dates that do not exist', () {
      // DateTime would quietly roll these forward into a different day.
      expect(() => DailyDateService.parse('2026-02-30'), throwsFormatException);
      expect(() => DailyDateService.parse('2026-13-01'), throwsFormatException);
      expect(() => DailyDateService.parse('2027-02-29'), throwsFormatException);
      // ...but a real leap day is fine.
      expect(DailyDateService.parse('2028-02-29').day, 29);
    });

    test('ignores time of day — a day is a calendar date, not 24 hours', () {
      expect(
        DailyDateService.format(DateTime(2026, 8, 26, 23, 59, 59)),
        DailyDateService.format(DateTime(2026, 8, 26, 0, 0, 1)),
      );
    });
  });

  group('daysBetween', () {
    test('counts forwards and backwards', () {
      expect(DailyDateService.daysBetween('2026-08-25', '2026-08-26'), 1);
      expect(DailyDateService.daysBetween('2026-08-26', '2026-08-25'), -1);
      expect(DailyDateService.daysBetween('2026-08-26', '2026-08-26'), 0);
    });

    test('crosses month and year boundaries', () {
      expect(DailyDateService.daysBetween('2026-08-31', '2026-09-01'), 1);
      expect(DailyDateService.daysBetween('2026-12-31', '2027-01-01'), 1);
    });

    test('handles a leap day', () {
      expect(DailyDateService.daysBetween('2028-02-28', '2028-02-29'), 1);
      expect(DailyDateService.daysBetween('2028-02-29', '2028-03-01'), 1);
    });

    test('survives a DST transition', () {
      // Where DST applies, these two dates are 23 or 25 hours apart, but they
      // are still one calendar day — the rounding in daysBetween covers it.
      expect(DailyDateService.daysBetween('2026-03-28', '2026-03-29'), 1);
      expect(DailyDateService.daysBetween('2026-10-24', '2026-10-25'), 1);
    });
  });

  test('isConsecutive is strictly forwards by one', () {
    expect(DailyDateService.isConsecutive('2026-08-25', '2026-08-26'), isTrue);
    expect(DailyDateService.isConsecutive('2026-08-26', '2026-08-25'), isFalse);
    expect(DailyDateService.isConsecutive('2026-08-24', '2026-08-26'), isFalse);
  });

  test('names the weekday and month day', () {
    expect(DailyDateService.weekdayName('2026-08-26'), 'Wednesday');
    expect(DailyDateService.monthDay('2026-08-26'), 'August 26');
  });
}
