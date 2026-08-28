import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../../../core/providers.dart';
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

final dailyFunProvider = FutureProvider<DailyFun>((ref) async {
  final date = ref.watch(currentDateProvider);
  final result = await ref.watch(funRepositoryProvider).funFor(date);
  return switch (result) {
    Success<DailyFun>(:final data) => data,
    Failure<DailyFun>(:final error) => throw error,
  };
});

/// Explore always shows both animals, regardless of which one the daily
/// rotation picked — asking for a dog and getting only a cat is a let-down.
final dailyCatProvider = FutureProvider<DailyFun>(
  (ref) => _kind(ref, FunKind.cat),
);

final dailyDogProvider = FutureProvider<DailyFun>(
  (ref) => _kind(ref, FunKind.dog),
);

/// The rotating slot, but only when it is something other than a cat or dog —
/// those already have dedicated cards, and showing them twice is noise.
final dailyExtraFunProvider = Provider<FunKind?>((ref) {
  final kind = FunKind.forDate(ref.watch(currentDateProvider));
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
