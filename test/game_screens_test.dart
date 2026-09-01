import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/core/providers.dart';
import 'package:daily_ritual/features/games/presentation/game_2048_screen.dart';
import 'package:daily_ritual/features/games/presentation/games_screen.dart';
import 'package:daily_ritual/features/games/presentation/quant_rush_screen.dart';
import 'package:daily_ritual/features/games/presentation/sudoku_screen.dart';
import 'package:daily_ritual/features/games/providers/game_providers.dart';
import 'package:daily_ritual/features/gym/domain/workout.dart';
import 'package:daily_ritual/features/gym/presentation/gym_screen.dart';
import 'package:daily_ritual/features/gym/providers/gym_providers.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// These screens all render inside `DetailScaffold`, which already wraps its
/// child in a scroll view. Handing it a ListView gives that list unbounded
/// height, and it silently collapses to nothing — the screen keeps its header
/// and loses its entire body, with no exception to notice.
///
/// That shipped once. These tests exist so it cannot ship again: each one
/// asserts the body actually rendered, not merely that the widget built.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  // The live drift streams keep timers alive past the end of a test, which
  // the binding reports as a failure. These screens are being checked for
  // layout, so the streams are stubbed and the database is left for the
  // one-shot reads and writes the screens still make.
  Widget host(Widget screen) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      currentDateProvider.overrideWith(() => _FixedDate('2026-09-01')),
      gameScoresProvider.overrideWith((ref) => Stream.value(const [])),
      weeklySplitProvider.overrideWith(
        (ref) => Stream.value(WeeklySplit.defaults),
      ),
      todayWorkoutLogProvider.overrideWith((ref) => Stream.value(null)),
      todaySessionProvider.overrideWith((ref) async => const <Exercise>[]),
      allWorkoutLogsProvider.overrideWith((ref) => Stream.value(const [])),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => screen)],
      ),
    ),
  );

  testWidgets('the Play hub lists every game', (tester) async {
    await tester.pumpWidget(host(const GamesScreen()));
    await tester.pump();

    expect(find.text('Quant Rush'), findsOneWidget);
    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.text('2048'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('Sudoku shows its difficulty picker, not an empty page', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SudokuScreen()));
    await tester.pump();

    expect(find.text('Pick a difficulty'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('Sudoku deals a board once a difficulty is chosen', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SudokuScreen()));
    await tester.pump();

    await tester.tap(find.text('Easy'));
    await tester.pump();
    // Generation yields a frame before it runs, so the spinner can paint.
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.text('Notes off'), findsOneWidget);
    expect(find.text('New puzzle'), findsOneWidget);
    // The keypad's nine digits are proof the board actually laid out.
    expect(find.text('9'), findsWidgets);
  });

  testWidgets('2048 renders a board with tiles on it', (tester) async {
    await tester.pumpWidget(host(const Game2048Screen()));
    // The board is restored asynchronously, so the first frame is a spinner.
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // Eyebrow uppercases its label.
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('New game'), findsOneWidget);
    // Two starting tiles means the board really laid out. A spawn is a 2 or,
    // one time in ten, a 4 — so asserting on '2' alone is a flake.
    expect(
      find.text('2').evaluate().length + find.text('4').evaluate().length,
      greaterThanOrEqualTo(2),
    );
  });

  testWidgets('Quant Rush shows its intro and can start a run', (tester) async {
    await tester.pumpWidget(host(const QuantRushScreen()));
    await tester.pump();

    expect(find.text('60 seconds'), findsOneWidget);
    // PrimaryButton uppercases its label.
    expect(find.text('START'), findsOneWidget);

    await tester.tap(find.text('START'));
    await tester.pump();

    // A live round means a running clock and a live score line.
    expect(find.text('0:60'), findsOneWidget);
    expect(find.text('0 correct'), findsOneWidget);

    // Step the clock rather than settling: the run is driven by a periodic
    // timer, and pumpAndSettle would wait on it forever.
    for (var second = 0; second < 61; second++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // The run ended and was scored.
    expect(find.text('AGAIN'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('Gym shows today\'s focus and the split editor', (tester) async {
    await tester.pumpWidget(host(const GymScreen()));
    await tester.pump();
    await tester.pump();

    // 2026-09-01 is a Tuesday, which the default split trains as Back.
    expect(find.text('Back'), findsWidgets);
    expect(find.text('YOUR SPLIT'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
  });
}

class _FixedDate extends CurrentDateNotifier {
  _FixedDate(this._date);
  final String _date;

  @override
  String build() => _date;
}
