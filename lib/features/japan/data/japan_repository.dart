import '../../../core/database/database.dart';
import '../domain/japan_entry.dart';
import 'japan_source.dart';

class JapanRepository {
  const JapanRepository(this._source, this._db);

  final JapanSource _source;
  final AppDatabase _db;

  static const _contentType = 'japan';

  Future<JapanEntry?> entryFor(String date) async {
    final cached = await _db.readContent(date, _contentType);
    if (cached != null) {
      try {
        return JapanEntry.fromJson(cached);
      } on Object {
        await _db.deleteContent(date, _contentType);
      }
    }

    final entry = await _source.entryFor(date);
    if (entry == null) return null;

    await _db.writeContent(
      date: date,
      contentType: _contentType,
      source: 'Wikipedia',
      sourceId: entry.title,
      payload: entry.toJson(),
    );
    return entry;
  }
}
