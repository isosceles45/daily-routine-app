import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/daily_seed.dart';
import '../domain/workout.dart';
import 'wger_service.dart';

/// The split, the suggestions and the log.
///
/// The split is local and can never fail. Suggestions come from wger and are
/// cached per day, so a session you have already opened stays available with
/// no signal — the same cache-first rule the rest of the app follows.
class GymRepository {
  const GymRepository(this._service, this._db);

  final WgerService _service;
  final AppDatabase _db;

  static String _contentType(MuscleFocus focus) => 'gym:${focus.name}';

  /// How many of the fetched pool to actually put in front of the user.
  static const sessionSize = 6;

  // --- The split ----------------------------------------------------------

  Stream<WeeklySplit> watchSplit() {
    return _db.select(_db.workoutSlots).watch().map((rows) {
      if (rows.isEmpty) return WeeklySplit.defaults;
      return WeeklySplit({
        for (final row in rows) row.weekday: MuscleFocus.fromName(row.focus),
      });
    });
  }

  Future<void> setFocus(int weekday, MuscleFocus focus) {
    return _db
        .into(_db.workoutSlots)
        .insertOnConflictUpdate(
          WorkoutSlotsCompanion.insert(
            // SQLite makes an INTEGER PRIMARY KEY an alias for rowid, so Drift
            // treats it as assignable rather than required.
            weekday: Value(weekday),
            focus: focus.name,
            wgerCategory: Value(focus.wgerCategory),
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// Writes the default split out as real rows.
  ///
  /// Until this runs the split is only a default in memory; persisting it is
  /// what lets a single day be edited without inventing the other six.
  Future<void> materialiseDefaults() async {
    final existing = await _db.select(_db.workoutSlots).get();
    if (existing.isNotEmpty) return;

    for (final weekday in WeeklySplit.weekdayOrder) {
      await setFocus(weekday, WeeklySplit.defaults.focusFor(weekday));
    }
  }

  // --- Suggestions --------------------------------------------------------

  /// Today's exercises for [focus], cached per day.
  ///
  /// The pool from wger is larger than a session, so the day's seed picks a
  /// stable subset — the same day always shows the same session, but two
  /// chest days a week apart are not identical.
  Future<List<Exercise>> sessionFor(String date, MuscleFocus focus) async {
    if (focus.isRest) return const [];

    final cached = await _db.readContent(date, _contentType(focus));
    if (cached != null) {
      try {
        final list = (cached['exercises'] as List<dynamic>)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      } on Object {
        await _db.deleteContent(date, _contentType(focus));
      }
    }

    final category = focus.wgerCategory;
    if (category == null) return const [];

    final result = await _service.exercisesFor(category);
    if (result case Success<List<Exercise>>(:final data) when data.isNotEmpty) {
      final picked = _pick(data, date, focus);
      await _db.writeContent(
        date: date,
        contentType: _contentType(focus),
        source: 'wger',
        sourceId: '$category',
        payload: {
          'exercises': [for (final e in picked) e.toJson()],
        },
      );
      return picked;
    }

    return const [];
  }

  /// A stable per-day subset of the pool.
  static List<Exercise> _pick(
    List<Exercise> pool,
    String date,
    MuscleFocus focus,
  ) {
    final shuffled = [...pool]..shuffle(dailyRandom(date, 'gym-${focus.name}'));
    return shuffled.take(sessionSize).toList(growable: false);
  }

  /// Drops today's cached session so a new one can be drawn.
  Future<void> reshuffle(String date, MuscleFocus focus) =>
      _db.deleteContent(date, _contentType(focus));

  // --- The log ------------------------------------------------------------

  Stream<WorkoutLog?> watchLog(String date) {
    return (_db.select(
      _db.workoutLogs,
    )..where((t) => t.date.equals(date))).watchSingleOrNull();
  }

  Future<Set<String>> _doneOn(String date) async {
    final log = await (_db.select(
      _db.workoutLogs,
    )..where((t) => t.date.equals(date))).getSingleOrNull();

    final raw = log?.done;
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
    } on FormatException {
      return {};
    }
  }

  /// Ticks an exercise off, or un-ticks it.
  Future<void> toggleExercise({
    required String date,
    required MuscleFocus focus,
    required String exercise,
  }) async {
    final done = await _doneOn(date);
    if (!done.remove(exercise)) done.add(exercise);

    await _db
        .into(_db.workoutLogs)
        .insertOnConflictUpdate(
          WorkoutLogsCompanion.insert(
            date: date,
            focus: focus.name,
            done: Value(jsonEncode(done.toList())),
            // A session counts as done the moment anything is ticked: showing
            // up is the thing being tracked, not finishing a prescribed list.
            completed: Value(done.isNotEmpty),
            completedAt: Value(done.isEmpty ? null : DateTime.now()),
          ),
        );
  }

  Future<void> clear(String date) =>
      (_db.delete(_db.workoutLogs)..where((t) => t.date.equals(date))).go();

  Stream<List<WorkoutLog>> watchAllLogs() =>
      _db.select(_db.workoutLogs).watch();

  static Set<String> doneFrom(WorkoutLog? log) {
    final raw = log?.done;
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
    } on FormatException {
      return {};
    }
  }
}
