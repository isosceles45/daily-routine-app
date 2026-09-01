import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/providers.dart';
import '../../../core/utils/daily_seed.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/fun_repository.dart';
import '../data/fun_service.dart';
import '../domain/daily_fun.dart';

final funServiceProvider = Provider<FunService>(
  (ref) => FunService(ref.watch(apiClientProvider)),
);

final funRepositoryProvider = Provider<FunRepository>(
  (ref) =>
      FunRepository(ref.watch(funServiceProvider), ref.watch(databaseProvider)),
);

/// The day's rotating kind, after applying the user's preferences.
final dailyFunKindProvider = Provider<FunKind>((ref) {
  final kind = FunKind.forDate(ref.watch(currentDateProvider));
  final allowDark =
      ref.watch(preferencesProvider).value?.allowDarkJokes ?? true;

  // Saturday is dark-joke day; swap it for an ordinary one when asked.
  return (kind == FunKind.darkJoke && !allowDark) ? FunKind.joke : kind;
});

final dailyFunProvider = FutureProvider<DailyFun>((ref) async {
  final date = ref.watch(currentDateProvider);
  final kind = ref.watch(dailyFunKindProvider);
  final result = await ref.watch(funRepositoryProvider).kindFor(date, kind);
  return switch (result) {
    Success<DailyFun>(:final data) => data,
    Failure<DailyFun>(:final error) => throw error,
  };
});

/// The day's animal, chosen from the whole menagerie.
///
/// Deliberately independent of [dailyFunKindProvider]: Tuesday's rotation is a
/// joke, but Explore should still have an animal on it. Both use the same
/// `fun-animal` seed, so on an animal day they agree.
final animalOfTheDayKindProvider = Provider<FunKind>(
  (ref) =>
      dailyPick(ref.watch(currentDateProvider), 'fun-animal', FunKind.animals),
);

final animalOfTheDayProvider = FutureProvider<DailyFun>(
  (ref) => _kind(ref, ref.watch(animalOfTheDayKindProvider)),
);

/// A freshly fetched animal, deliberately *outside* the daily cache.
///
/// This is what makes the menagerie something you can keep pulling on rather
/// than a once-a-day card. [nonce] is what makes "another one" actually fetch
/// another one — same species, new request.
final freshAnimalProvider =
    FutureProvider.family<DailyFun, ({FunKind kind, int nonce})>((
      ref,
      args,
    ) async {
      final result = await ref.watch(funServiceProvider).fetch(args.kind);
      return switch (result) {
        Success<DailyFun>(:final data) => data,
        Failure<DailyFun>(:final error) => throw error,
      };
    });

/// The rotating slot, but only when it is something other than a cat or dog —
/// those already have dedicated cards, and showing them twice is noise.
final dailyExtraFunProvider = Provider<FunKind?>((ref) {
  final kind = ref.watch(dailyFunKindProvider);
  return (kind == FunKind.cat || kind == FunKind.dog) ? null : kind;
});

Future<DailyFun> _kind(Ref ref, FunKind kind) async {
  final date = ref.watch(currentDateProvider);
  final result = await ref.watch(funRepositoryProvider).kindFor(date, kind);
  return switch (result) {
    Success<DailyFun>(:final data) => data,
    Failure<DailyFun>(:final error) => throw error,
  };
}
