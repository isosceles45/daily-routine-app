import '../../../core/database/database.dart';
import '../../../core/network/api_result.dart';
import '../domain/daily_fun.dart';
import 'fun_service.dart';

class FunRepository {
  const FunRepository(this._service, this._db);

  final FunService _service;
  final AppDatabase _db;

  /// The day's rotating slot (§9). Delegates to [kindFor] so that when the
  /// rotation lands on cat or dog it shares the cache with the Explore cards
  /// instead of fetching a second, different animal.
  Future<ApiResult<DailyFun>> funFor(String date) =>
      kindFor(date, FunKind.forDate(date));

  /// A specific flavour for the day, cached per kind so the cat and the dog on
  /// Explore each stay put across restarts.
  Future<ApiResult<DailyFun>> kindFor(String date, FunKind kind) async {
    final contentType = 'fun-${kind.name}';

    final cached = await _db.readContent(date, contentType);
    if (cached != null) {
      try {
        return Success(DailyFun.fromJson(cached));
      } on Object {
        await _db.deleteContent(date, contentType);
      }
    }

    final result = await _service.fetch(kind);

    if (result case Success<DailyFun>(:final data)) {
      await _db.writeContent(
        date: date,
        contentType: contentType,
        source: data.source,
        sourceId: data.kind.name,
        payload: data.toJson(),
      );
    }

    return result;
  }
}
