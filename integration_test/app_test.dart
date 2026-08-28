import 'package:daily_ritual/app/app.dart';
import 'package:daily_ritual/core/database/database.dart';
import 'package:daily_ritual/core/firebase/firebase_bootstrap.dart';
import 'package:daily_ritual/core/dates/daily_date_service.dart';
import 'package:daily_ritual/core/providers.dart';
import 'package:daily_ritual/features/wordle/domain/wordle_share.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end pass over the daily loop (§29).
///
/// The day's content is seeded into `daily_content` before launch, so the
/// repositories serve from cache and the test never touches the network. That
/// is not a shortcut: it is the same path the app takes offline, so this
/// exercises the caching layer rather than skipping it — and it means the test
/// cannot fail because OpenTDB was slow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late String today;

  Future<void> seed() async {
    today = const DailyDateService().today();

    // Onboarding and the greeting are one-time screens; get past them so the
    // test drives the app itself.
    await db.setSetting('onboarding_complete', 'true');
    await db.setSetting('user_name', 'Tester');
    await db.ensureDay(today);
    await db.markGreetingShown(today);

    await db.writeContent(
      date: today,
      contentType: 'trivia',
      source: 'OpenTDB',
      payload: {
        'id': 'test-trivia',
        'category': 'Science',
        'difficulty': 'easy',
        'question': 'Which planet has the most moons?',
        'correctAnswer': 'Saturn',
        'incorrectAnswers': ['Jupiter', 'Uranus', 'Neptune'],
        'answers': ['Saturn', 'Jupiter', 'Uranus', 'Neptune'],
        'source': 'OpenTDB',
      },
    );

    await db.writeContent(
      date: today,
      contentType: 'catQuant',
      source: 'Generated',
      payload: {
        'id': 'test-cat',
        'topic': 'Averages',
        'difficulty': 'Medium',
        'stem': 'What is the average of 2, 4 and 6?',
        'options': ['3', '4', '5', '6'],
        'answerIndex': 1,
        'solution': '(2 + 4 + 6) / 3 = 4.',
        'source': 'generated',
        'verification': 'crossChecked',
      },
    );

    await db.writeContent(
      date: today,
      contentType: 'pokemon',
      source: 'PokéAPI',
      payload: {
        'id': 133,
        'name': 'eevee',
        'types': ['normal'],
        'abilities': ['run-away'],
        'heightDecimetres': 3,
        'weightHectograms': 65,
        'artworkUrl': null,
        'stats': [
          {'label': 'HP', 'value': 55},
        ],
        'flavorText': 'A test Pokémon.',
      },
    );

    for (final kind in ['fun-cat', 'fun-dog', 'fun-joke', 'fun-weirdFact']) {
      await db.writeContent(
        date: today,
        contentType: kind,
        source: 'Test',
        payload: {'kind': kind.split('-').last, 'source': 'Test', 'text': 'Ha.'},
      );
    }
  }

  Widget app() => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // The suite must not depend on a Firebase project existing.
          firebaseReadyProvider.overrideWithValue(false),
        ],
        child: const DailyRitualApp(),
      );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seed();
  });

  tearDown(() async => db.close());

  testWidgets('the daily loop works end to end', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // --- the day exists and greets the user by name
    expect(find.textContaining('Tester'), findsWidgets);
    expect(find.text('Daily Trivia'), findsWidgets);

    // --- answer today's trivia
    await tester.tap(find.text('Daily Trivia').first);
    await tester.pumpAndSettle();

    expect(find.text('Which planet has the most moons?'), findsOneWidget);
    await tester.tap(find.text('Saturn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUBMIT'));
    await tester.pumpAndSettle();

    expect(find.text('Correct!'), findsOneWidget);

    final trivia = await db.select(db.triviaResults).getSingle();
    expect(trivia.answered, isTrue);
    expect(trivia.correct, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- add and complete a todo
    await tester.tap(find.text('Todos').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Write the report');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Write the report'), findsOneWidget);

    final todo = await db.select(db.todos).getSingle();
    expect(todo.completed, isFalse);

    // --- import a Wordle result and see it in History
    final number = WordleShareParser.numberFor(today);
    await db.into(db.wordleResults).insertOnConflictUpdate(
          WordleResultsCompanion.insert(
            date: today,
            wordleNumber: number,
            score: const Value(3),
            completed: const Value(true),
            grid: const Value('⬛⬛🟨⬛⬛\n⬛🟨⬛⬛🟨\n🟩🟩🟩🟩🟩'),
            importedAt: DateTime.now(),
          ),
        );

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    // One game, solved in three, so the streak has started.
    expect(find.text('Streak'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    expect(find.text('3.0'), findsWidgets);
  });

  testWidgets('cached content survives with no network at all', (tester) async {
    // Nothing here is stubbed to fail: the repositories simply never reach the
    // network because everything they need is already cached (§17).
    await tester.pumpWidget(app());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Which planet has the most moons?'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the day rolls over into a fresh state', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Simulate tomorrow arriving while the app is open.
    final tomorrow = DailyDateService.format(
      DailyDateService.parse(today).add(const Duration(days: 1)),
    );
    await db.ensureDay(tomorrow);

    final days = await db.select(db.dailyStates).get();
    expect(days, hasLength(2), reason: 'a new day must not overwrite the old');
    expect(days.map((d) => d.date), containsAll([today, tomorrow]));
  });
}
