import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/providers.dart';
import '../../animals/providers/fun_providers.dart';
import '../../japan/providers/japan_providers.dart';
import '../../pokemon/providers/pokemon_providers.dart';
import '../data/surprise_generator.dart';
import '../domain/surprise_pack.dart';

final surpriseGeneratorProvider = Provider<SurpriseGenerator>(
  (ref) => SurpriseGenerator(
    client: ref.watch(apiClientProvider),
    funService: ref.watch(funServiceProvider),
    pokemonService: ref.watch(pokemonServiceProvider),
    japanSource: ref.watch(japanSourceProvider),
  ),
);

/// The current surprise. Re-rolling replaces it; the day's official content is
/// untouched either way (§12).
class SurpriseNotifier extends AsyncNotifier<SurprisePack?> {
  @override
  Future<SurprisePack?> build() async {
    // Show the most recent saved pack rather than firing five requests the
    // moment the screen opens — offline, this is the whole feature.
    final date = ref.watch(currentDateProvider);
    final db = ref.watch(databaseProvider);

    final latest =
        await (db.select(db.surprises)
              ..where((t) => t.date.equals(date))
              ..orderBy([(t) => OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();

    if (latest == null) return null;
    try {
      return SurprisePack.fromJson(
        jsonDecode(latest.payload) as Map<String, dynamic>,
      );
    } on Object {
      return null;
    }
  }

  Future<void> roll() async {
    state = const AsyncLoading();

    try {
      final pack = await ref.read(surpriseGeneratorProvider).generate();
      if (pack.isEmpty) {
        state = AsyncError(Exception('No source answered'), StackTrace.current);
        return;
      }

      final db = ref.read(databaseProvider);
      await db
          .into(db.surprises)
          .insert(
            SurprisesCompanion.insert(
              date: ref.read(currentDateProvider),
              payload: jsonEncode(pack.toJson()),
              createdAt: DateTime.now(),
            ),
          );

      state = AsyncData(pack);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }
}

final surpriseProvider = AsyncNotifierProvider<SurpriseNotifier, SurprisePack?>(
  SurpriseNotifier.new,
);

/// How many packs have been rolled today. Shown on the pack itself, so it
/// reads as something you pulled rather than something that was there.
final surpriseCountProvider = StreamProvider<int>((ref) {
  final date = ref.watch(currentDateProvider);
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.surprises,
  )..where((t) => t.date.equals(date))).watch().map((rows) => rows.length);
});

/// Whether a surprise has been generated today, for daily completion.
final surpriseGeneratedProvider = Provider<bool>(
  (ref) => ref.watch(surpriseProvider).value != null,
);
