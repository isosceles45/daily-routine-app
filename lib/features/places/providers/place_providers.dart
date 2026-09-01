import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/place_repository.dart';
import '../data/place_source.dart';
import '../domain/place_entry.dart';

/// Swapping the data source means changing this one line (§11).
final placeSourceProvider = Provider<PlaceSource>(
  (ref) => WikipediaPlaceSource(ref.watch(apiClientProvider)),
);

final placeRepositoryProvider = Provider<PlaceRepository>(
  (ref) => PlaceRepository(
    ref.watch(placeSourceProvider),
    ref.watch(databaseProvider),
  ),
);

final placeOfTheDayProvider = FutureProvider<PlaceEntry?>((ref) async {
  final date = ref.watch(currentDateProvider);
  return ref.watch(placeRepositoryProvider).entryFor(date);
});
