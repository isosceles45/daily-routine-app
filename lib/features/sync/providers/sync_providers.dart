import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/account_service.dart';
import '../data/sync_service.dart';
import '../domain/sync_state.dart';

/// Whether sync can be offered at all: the packages are present, Firebase
/// started, and the user has switched it on.
final syncAvailableProvider = Provider<bool>(
  (ref) => ref.watch(firebaseReadyProvider),
);

final syncEnabledProvider = Provider<bool>(
  (ref) => ref.watch(preferencesProvider).value?.syncEnabled ?? false,
);

/// Backup and cross-device sync.
///
/// Off by default and never started implicitly — onboarding promises nothing
/// is uploaded, and that stays true until the user says otherwise.
class SyncController extends AsyncNotifier<SyncState> {
  @override
  Future<SyncState> build() async {
    if (!ref.watch(syncAvailableProvider)) return SyncState.off;
    if (!ref.watch(syncEnabledProvider)) return SyncState.off;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SyncState(phase: SyncPhase.signedOut);
    }
    return SyncState(
      phase: SyncPhase.idle,
      isAnonymous: user.isAnonymous,
      email: user.email,
    );
  }

  /// Switches sync on: signs in anonymously, then does a first full sync so
  /// the user sees it work rather than being told it will.
  Future<void> enable() async {
    await ref.read(preferencesProvider.notifier).setSyncEnabled(true);
    await syncNow();
  }

  /// Switches sync off. The cloud copy is deliberately left alone — turning
  /// sync off should not destroy a backup the user may be relying on.
  Future<void> disable() async {
    await ref.read(preferencesProvider.notifier).setSyncEnabled(false);
    state = const AsyncData(SyncState.off);
  }

  Future<void> syncNow() async {
    if (!ref.read(syncAvailableProvider)) return;

    final previous = state.value ?? SyncState.off;
    state = AsyncData(previous.copyWith(phase: SyncPhase.running));

    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user == null) {
        state = AsyncData(
          previous.copyWith(
            phase: SyncPhase.failed,
            message: "Couldn't sign in.",
          ),
        );
        return;
      }

      final service = SyncService(
        db: ref.read(databaseProvider),
        firestore: FirebaseFirestore.instance,
        uid: user.uid,
      );
      final written = await service.syncAll();

      state = AsyncData(
        SyncState(
          phase: SyncPhase.idle,
          lastSyncedAt: DateTime.now(),
          recordCount: written,
          isAnonymous: user.isAnonymous,
        ),
      );
    } catch (error) {
      // Sync failing must never be something the user has to deal with; it
      // reports and stops there.
      state = AsyncData(
        previous.copyWith(phase: SyncPhase.failed, message: _readable(error)),
      );
    }
  }

  static String _readable(Object error) {
    final text = '$error';
    if (text.contains('network') || text.contains('unavailable')) {
      return "Couldn't reach the server.";
    }
    if (text.contains('permission-denied')) {
      return 'The server refused the write — check the Firestore rules.';
    }
    return "Sync didn't complete.";
  }
}

final syncControllerProvider = AsyncNotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

final accountServiceProvider = Provider<AccountService>(
  (ref) => const AccountService(),
);

/// Attaches a Google account to the current anonymous one, then syncs so the
/// result is visible immediately rather than promised.
Future<LinkOutcome> linkGoogleAccount(WidgetRef ref) async {
  final outcome = await ref.read(accountServiceProvider).linkGoogle();

  if (outcome is LinkedInPlace || outcome is SignedInToExisting) {
    ref.invalidate(syncControllerProvider);
    await ref.read(syncControllerProvider.notifier).syncNow();
  }
  return outcome;
}

/// Signs out. Sync is switched off with it — leaving it on with no account
/// would just fail silently on every attempt.
Future<void> signOutOfSync(WidgetRef ref) async {
  await ref.read(accountServiceProvider).signOut();
  await ref.read(syncControllerProvider.notifier).disable();
  ref.invalidate(syncControllerProvider);
}
