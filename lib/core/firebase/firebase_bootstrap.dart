import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether Firebase started up.
///
/// Overridden in `main` with the real result. It is false whenever the
/// platform config is missing — a checkout without `google-services.json`, or
/// iOS before its plist is added — and the whole sync feature simply hides
/// itself rather than the app failing to launch.
final firebaseReadyProvider = Provider<bool>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

/// Initialises Firebase, returning false rather than throwing.
///
/// The app is local-first and fully usable with no backend at all, so a
/// missing or broken Firebase config must never be fatal.
Future<bool> initialiseFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (error) {
    debugPrint('Firebase unavailable, continuing offline-only: $error');
    return false;
  }
}
