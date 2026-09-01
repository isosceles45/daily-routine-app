import 'package:daily_ritual/features/gym/data/wger_service.dart';
import 'package:daily_ritual/features/gym/domain/workout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklySplit', () {
    test('the default week trains six days and rests on Sunday', () {
      expect(WeeklySplit.defaults.trainingDays, 6);
      expect(WeeklySplit.defaults.focusFor(DateTime.sunday), MuscleFocus.rest);
    });

    test('resolves a focus from a calendar date', () {
      // 2026-09-01 is a Tuesday.
      expect(WeeklySplit.defaults.focusOn('2026-09-01'), MuscleFocus.back);
      // 2026-09-06 is a Sunday.
      expect(WeeklySplit.defaults.focusOn('2026-09-06'), MuscleFocus.rest);
    });

    test('editing one day leaves the rest alone', () {
      final edited = WeeklySplit.defaults.withFocus(
        DateTime.sunday,
        MuscleFocus.cardio,
      );

      expect(edited.focusFor(DateTime.sunday), MuscleFocus.cardio);
      expect(edited.focusFor(DateTime.monday), MuscleFocus.chest);
      expect(edited.trainingDays, 7);
      // The original is untouched.
      expect(WeeklySplit.defaults.focusFor(DateTime.sunday), MuscleFocus.rest);
    });

    test('an unknown focus name degrades to rest rather than throwing', () {
      expect(MuscleFocus.fromName('nonsense'), MuscleFocus.rest);
      expect(MuscleFocus.fromName(null), MuscleFocus.rest);
    });

    test('every non-rest focus can fetch suggestions', () {
      for (final focus in MuscleFocus.values) {
        if (focus.isRest) {
          expect(focus.wgerCategory, isNull);
        } else {
          expect(focus.wgerCategory, isNotNull, reason: focus.name);
        }
      }
    });
  });

  group('wger description stripping', () {
    test('turns the HTML wger ships into readable text', () {
      const html = '<p>Rest on your palms.</p><p>Step with your R palm.</p>';
      expect(
        WgerService.stripHtml(html),
        'Rest on your palms.\nStep with your R palm.',
      );
    });

    test('decodes the entities that would otherwise show raw', () {
      expect(
        WgerService.stripHtml(
          '<p>Basical&nbsp;&amp; simple &quot;form&quot;</p>',
        ),
        'Basical & simple "form"',
      );
    });

    test('renders list items as bullets', () {
      expect(
        WgerService.stripHtml('<ul><li>One</li><li>Two</li></ul>'),
        '• One\n• Two',
      );
    });

    test('null and empty stay null rather than becoming an empty card', () {
      expect(WgerService.stripHtml(null), isNull);
      expect(WgerService.stripHtml('<p></p>'), isNull);
    });
  });
}
