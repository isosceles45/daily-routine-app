import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../../core/database/database.dart';

/// Describes one table's mirror into Firestore.
///
/// Every synced table is the same shape — rows with a primary key and a
/// timestamp — so they share one implementation rather than six near-identical
/// ones.
class TableMirror {
  const TableMirror({
    required this.collection,
    required this.idKey,
    required this.updatedKey,
    required this.read,
    required this.write,
  });

  /// Firestore collection under `users/{uid}/`.
  final String collection;

  /// Which field in the row's JSON is the document id.
  final String idKey;

  /// Which field decides who wins a conflict. Missing or null sorts oldest.
  final String updatedKey;

  final Future<List<Map<String, dynamic>>> Function() read;
  final Future<void> Function(Map<String, dynamic> row) write;
}

/// Mirrors local data to Firestore and back.
///
/// Drift stays the source of truth throughout: this pushes what is local and
/// pulls back anything newer, but the app never waits on it and never fails
/// because of it.
class SyncService {
  SyncService({required this.db, required this.firestore, required this.uid});

  final AppDatabase db;
  final FirebaseFirestore firestore;
  final String uid;

  /// Ints rather than strings for DateTime, so what lands in Firestore is
  /// plain JSON and round-trips through `fromJson` unchanged.
  static const serializer = ValueSerializer.defaults();

  List<TableMirror> get _mirrors => [
    TableMirror(
      collection: 'todos',
      idKey: 'id',
      updatedKey: 'updatedAt',
      read: () async => (await db.select(db.todos).get())
          .map((r) => r.toJson(serializer: serializer))
          .toList(),
      write: (row) => db
          .into(db.todos)
          .insertOnConflictUpdate(Todo.fromJson(row, serializer: serializer)),
    ),
    TableMirror(
      collection: 'wordle_results',
      idKey: 'date',
      updatedKey: 'importedAt',
      read: () async => (await db.select(db.wordleResults).get())
          .map((r) => r.toJson(serializer: serializer))
          .toList(),
      write: (row) => db
          .into(db.wordleResults)
          .insertOnConflictUpdate(
            WordleResult.fromJson(row, serializer: serializer),
          ),
    ),
    TableMirror(
      collection: 'trivia_results',
      idKey: 'date',
      updatedKey: 'answeredAt',
      read: () async => (await db.select(db.triviaResults).get())
          .map((r) => r.toJson(serializer: serializer))
          .toList(),
      write: (row) => db
          .into(db.triviaResults)
          .insertOnConflictUpdate(
            TriviaResult.fromJson(row, serializer: serializer),
          ),
    ),
    TableMirror(
      collection: 'cat_quant_results',
      idKey: 'date',
      updatedKey: 'answeredAt',
      read: () async => (await db.select(db.catQuantResults).get())
          .map((r) => r.toJson(serializer: serializer))
          .toList(),
      write: (row) => db
          .into(db.catQuantResults)
          .insertOnConflictUpdate(
            CatQuantResult.fromJson(row, serializer: serializer),
          ),
    ),
    TableMirror(
      collection: 'daily_states',
      idKey: 'date',
      updatedKey: 'createdAt',
      read: () async => (await db.select(db.dailyStates).get())
          .map((r) => r.toJson(serializer: serializer))
          .toList(),
      write: (row) => db
          .into(db.dailyStates)
          .insertOnConflictUpdate(
            DailyState.fromJson(row, serializer: serializer),
          ),
    ),
    TableMirror(
      collection: 'app_settings',
      idKey: 'key',
      updatedKey: 'updatedAt',
      // Carries the `seen:` completion markers as well as preferences,
      // which is what makes a restored install show the right history.
      read: () async => (await db.select(db.appSettings).get())
          .map((r) => r.toJson(serializer: serializer))
          .toList(),
      write: (row) => db
          .into(db.appSettings)
          .insertOnConflictUpdate(
            AppSetting.fromJson(row, serializer: serializer),
          ),
    ),
  ];

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      firestore.collection('users').doc(uid).collection(name);

  /// Pulls anything newer from the cloud, then pushes anything newer locally.
  ///
  /// Returns how many records were written in either direction.
  Future<int> syncAll() async {
    var written = 0;
    for (final mirror in _mirrors) {
      written += await _syncTable(mirror);
    }
    return written;
  }

  Future<int> _syncTable(TableMirror mirror) async {
    final localRows = await mirror.read();
    final localById = {
      for (final row in localRows) '${row[mirror.idKey]}': row,
    };

    final snapshot = await _collection(mirror.collection).get();
    final remoteById = {for (final doc in snapshot.docs) doc.id: doc.data()};

    var written = 0;

    // Remote wins only when it is strictly newer, so a fresh install pulls
    // history down but an active device never loses today's work.
    for (final entry in remoteById.entries) {
      final local = localById[entry.key];
      if (local != null &&
          _stamp(local, mirror.updatedKey) >=
              _stamp(entry.value, mirror.updatedKey)) {
        continue;
      }
      await mirror.write(entry.value);
      written++;
    }

    // Push in one batch: six tables of small rows would otherwise be dozens
    // of round trips, and Firestore's free tier counts every write.
    final batch = firestore.batch();
    var queued = 0;

    for (final entry in localById.entries) {
      final remote = remoteById[entry.key];
      if (remote != null &&
          _stamp(remote, mirror.updatedKey) >=
              _stamp(entry.value, mirror.updatedKey)) {
        continue;
      }
      batch.set(_collection(mirror.collection).doc(entry.key), entry.value);
      queued++;
    }

    if (queued > 0) {
      await batch.commit();
      written += queued;
    }

    return written;
  }

  /// A row's timestamp as a comparable int. Null sorts oldest, so a row that
  /// has never been touched never beats one that has.
  static int _stamp(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is int) return value;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is DateTime) return value.millisecondsSinceEpoch;
    return -1;
  }
}
