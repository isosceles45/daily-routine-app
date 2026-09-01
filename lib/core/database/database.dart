import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/activity_tables.dart';
import 'tables/daily_tables.dart';
import 'tables/event_tables.dart';
import 'tables/game_tables.dart';
import 'tables/gym_tables.dart';
import 'tables/settings_tables.dart';
import 'tables/todo_tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    DailyStates,
    DailyContents,
    Challenges,
    WordleResults,
    TriviaResults,
    CatQuantResults,
    Surprises,
    Todos,
    AppSettings,
    Events,
    WorkoutSlots,
    WorkoutLogs,
    GameScores,
    PuzzleStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'daily_ritual'));

  @override
  int get schemaVersion => 2;

  /// v1 → v2 adds countdowns, the training split and the games.
  ///
  /// Purely additive: nothing existing is altered, so an upgrade cannot lose a
  /// todo, a streak or an imported Wordle result.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(events);
        await m.createTable(workoutSlots);
        await m.createTable(workoutLogs);
        await m.createTable(gameScores);
        await m.createTable(puzzleStates);
      }
    },
  );

  // --- Daily state --------------------------------------------------------

  Future<DailyState> ensureDay(String date) async {
    final existing = await (select(
      dailyStates,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
    if (existing != null) return existing;

    final row = DailyStatesCompanion.insert(
      date: date,
      createdAt: DateTime.now(),
    );
    await into(dailyStates).insert(row, mode: InsertMode.insertOrIgnore);
    return (select(dailyStates)..where((t) => t.date.equals(date))).getSingle();
  }

  Future<void> markGreetingShown(String date) async {
    await (update(dailyStates)..where((t) => t.date.equals(date))).write(
      const DailyStatesCompanion(greetingShown: Value(true)),
    );
  }

  /// Every day the app has seen, newest first.
  Future<List<DailyState>> recentDays({int limit = 30}) {
    return (select(dailyStates)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .get();
  }

  // --- Daily content cache ------------------------------------------------

  /// Returns the cached payload for [date]/[contentType], or null on a miss.
  Future<Map<String, dynamic>?> readContent(
    String date,
    String contentType,
  ) async {
    final row =
        await (select(dailyContents)..where(
              (t) => t.date.equals(date) & t.contentType.equals(contentType),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    try {
      return jsonDecode(row.payload) as Map<String, dynamic>;
    } on FormatException {
      // A corrupt row must never take down the home screen; drop it and
      // let the caller re-fetch.
      await deleteContent(date, contentType);
      return null;
    }
  }

  Future<void> writeContent({
    required String date,
    required String contentType,
    required String source,
    String? sourceId,
    required Map<String, dynamic> payload,
  }) async {
    await into(dailyContents).insertOnConflictUpdate(
      DailyContentsCompanion.insert(
        date: date,
        contentType: contentType,
        source: source,
        sourceId: Value(sourceId),
        payload: jsonEncode(payload),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteContent(String date, String contentType) {
    return (delete(dailyContents)..where(
          (t) => t.date.equals(date) & t.contentType.equals(contentType),
        ))
        .go();
  }

  // --- Settings -----------------------------------------------------------

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Every `seen:<date>:<activity>` marker, used to reconstruct which passive
  /// activities were viewed on each past day.
  Stream<List<AppSetting>> watchSeenMarkers() {
    return (select(appSettings)..where((t) => t.key.like('seen:%'))).watch();
  }

  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
