import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/japan_repository.dart';
import '../data/japan_source.dart';
import '../domain/japan_entry.dart';

/// Swapping the data source means changing this one line (§11).
final japanSourceProvider = Provider<JapanSource>(
  (ref) => WikipediaJapanSource(ref.watch(apiClientProvider)),
);

final japanRepositoryProvider = Provider<JapanRepository>(
  (ref) => JapanRepository(
    ref.watch(japanSourceProvider),
    ref.watch(databaseProvider),
  ),
);

final japanOfTheDayProvider = FutureProvider<JapanEntry?>((ref) async {
  final date = ref.watch(currentDateProvider);
  return ref.watch(japanRepositoryProvider).entryFor(date);
});
