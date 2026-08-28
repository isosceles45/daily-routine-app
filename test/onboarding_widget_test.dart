import 'package:daily_ritual/app/theme.dart';
import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/core/providers.dart';
import 'package:daily_ritual/features/onboarding/presentation/onboarding_screen.dart';
import 'package:daily_ritual/features/settings/providers/settings_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Onboarding is the first thing a new user sees, and it is the one screen
/// with no cached fallback if it fails. These tests exist because a `Spacer`
/// inside a `SingleChildScrollView` shipped once and took the whole screen
/// down — a scroll view hands its child unbounded height, which a Flexible
/// cannot divide.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget harness({VoidCallback? onDone}) => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildRitualTheme(),
          home: OnboardingScreen(onDone: onDone ?? () {}),
        ),
      );

  testWidgets('lays out without throwing', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ritual'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('fits a short screen without overflowing', (tester) async {
    // A small phone in landscape is the worst case for a tall form.
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the Start button stays on screen while the content scrolls',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // The button sits outside the scroll view on purpose, so it must remain
    // visible even after the content is scrolled away.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('START'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves the name and preferences, then reports done',
      (tester) async {
    var done = false;
    await tester.pumpWidget(harness(onDone: () => done = true));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Atharva');
    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    expect(done, isTrue);
    expect(await db.getSetting('user_name'), 'Atharva');
    expect(await db.getSetting('onboarding_complete'), 'true');
  });

  testWidgets('skipping the name still completes rather than blocking',
      (tester) async {
    var done = false;
    await tester.pumpWidget(harness(onDone: () => done = true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    expect(done, isTrue,
        reason: 'an empty name must not trap the user on onboarding');
  });

  testWidgets('marks today greeted so the user is not welcomed twice',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Atharva');
    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    final days = await db.select(db.dailyStates).get();
    expect(days, hasLength(1));
    expect(days.single.greetingShown, isTrue);
  });

  testWidgets('toggles are reflected in what gets saved', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // Dark jokes default on; turn them off and reminders on.
    await tester.tap(find.text('Dark jokes on Saturdays'));
    await tester.tap(find.text('Daily reminders'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    expect(await db.getSetting('allow_dark_jokes'), 'false');
    expect(await db.getSetting('daily_reminders'), 'true');
  });

  test('defaults leave notifications off', () {
    expect(AppPreferences.defaults.dailyReminders, isFalse);
  });
}
