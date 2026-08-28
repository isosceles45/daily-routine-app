import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/wordle/providers/wordle_providers.dart';
import 'providers.dart';

/// One-off repairs that run once per install, guarded by a flag.
///
/// These exist because data written by an earlier build can be wrong in ways a
/// schema migration can't express — the columns are fine, the values aren't.
abstract final class Maintenance {
  static const _wordleDatesKey = 'repair_wordle_dates_v1';

  static Future<void> run(Ref ref) async {
    final db = ref.read(databaseProvider);

    if (await db.getSetting(_wordleDatesKey) == null) {
      await ref.read(wordleRepositoryProvider).repairMisfiledDates();
      await db.setSetting(_wordleDatesKey, 'done');
    }
  }
}

/// Fires the repairs. Watched once at app level; failures are swallowed
/// because maintenance must never be the reason the app won't open.
final maintenanceProvider = FutureProvider<void>((ref) async {
  try {
    await Maintenance.run(ref);
  } catch (_) {
    // A repair that cannot run is not worth a broken launch.
  }
});
