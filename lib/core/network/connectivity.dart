import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device currently has a network route (§17).
///
/// This says nothing about whether a given API is reachable — that is what
/// [ApiErrorKind.offline] on a real request is for. This exists only so the UI
/// can explain *why* things look stale before the user taps anything.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  bool online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});

final isOfflineProvider = Provider<bool>(
  // Unknown is treated as online: showing an offline banner because a stream
  // hasn't emitted yet would be worse than showing nothing.
  (ref) => ref.watch(connectivityProvider).value == false,
);
