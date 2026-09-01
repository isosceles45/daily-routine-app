import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/core/providers.dart';
import 'package:daily_ritual/features/home/presentation/happy_new_day.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 1st is the one day the greeting does something extra, so it is the one
/// day it can break in a way no other test would catch.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  Widget harness(String date) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      currentDateProvider.overrideWith(() => _FixedDate(date)),
    ],
    child: MaterialApp(home: HappyNewDayOverlay(onDismiss: () {})),
  );

  testWidgets('the 1st shows the celebration above the greeting', (
    tester,
  ) async {
    await tester.pumpWidget(harness('2026-09-01'));
    await tester.pump();

    // The video cannot decode in a test binding, which is exactly the path a
    // device with a bad codec takes — it must still render, not throw.
    expect(find.text("It's the first of the month."), findsOneWidget);
    expect(find.textContaining('Happy New Day'), findsOneWidget);

    await _drain(tester);
  });

  testWidgets('an ordinary day shows no celebration', (tester) async {
    await tester.pumpWidget(harness('2026-09-02'));
    await tester.pump();

    expect(find.text("It's the first of the month."), findsNothing);
    expect(find.textContaining('Happy New Day'), findsOneWidget);

    await _drain(tester);
  });

  testWidgets('the greeting still dismisses itself on the 1st', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          currentDateProvider.overrideWith(() => _FixedDate('2026-09-01')),
        ],
        child: MaterialApp(
          home: HappyNewDayOverlay(onDismiss: () => dismissed = true),
        ),
      ),
    );
    await tester.pump();

    // Without a video it falls back to the ordinary hold rather than sitting
    // on a static banner for the length of a clip the user never saw.
    await tester.pump(const Duration(seconds: 4));
    expect(dismissed, isTrue);

    await tester.pumpAndSettle();
  });
  group('the gate', () {
    Widget gate(String date) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentDateProvider.overrideWith(() => _FixedDate(date)),
      ],
      child: MaterialApp(home: GreetingGate(child: const SizedBox.shrink())),
    );

    testWidgets('replays on the 1st even once the day is marked greeted', (
      tester,
    ) async {
      await db.ensureDay('2026-09-01');
      await db.markGreetingShown('2026-09-01');

      await tester.pumpWidget(gate('2026-09-01'));
      await tester.pump();
      await tester.pump();

      // Already greeted, but it is the 1st — the celebration plays anyway.
      expect(find.textContaining('Happy New Day'), findsOneWidget);

      await _drain(tester);
    });

    testWidgets('stays once-a-day on every other date', (tester) async {
      await db.ensureDay('2026-09-02');
      await db.markGreetingShown('2026-09-02');

      await tester.pumpWidget(gate('2026-09-02'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Happy New Day'), findsNothing);

      await _drain(tester);
    });
  });
}

/// Lets the overlay's auto-dismiss timer expire, so the test binding does not
/// flag it as still pending at teardown.
Future<void> _drain(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 7));
  await tester.pumpAndSettle();
}

class _FixedDate extends CurrentDateNotifier {
  _FixedDate(this._date);
  final String _date;

  @override
  String build() => _date;
}
