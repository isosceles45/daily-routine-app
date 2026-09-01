import '../../../core/database/database.dart';
import '../domain/place_entry.dart';
import 'place_source.dart';

class PlaceRepository {
  const PlaceRepository(this._source, this._db);

  final PlaceSource _source;
  final AppDatabase _db;

  // Deliberately not 'japan': rows cached by the Japan-only build carry no
  // region, so they are left behind rather than shown under a wrong country.
  static const _contentType = 'place';

  Future<PlaceEntry?> entryFor(String date) async {
    final cached = await _db.readContent(date, _contentType);
    if (cached != null) {
      try {
        return PlaceEntry.fromJson(cached);
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
