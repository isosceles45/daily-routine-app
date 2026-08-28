import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// What happened when the user tried to attach a Google account.
sealed class LinkOutcome {
  const LinkOutcome();
}

/// The anonymous account was upgraded in place: same uid, so everything
/// already synced stays where it is.
class LinkedInPlace extends LinkOutcome {
  const LinkedInPlace(this.email);
  final String? email;
}

/// This Google account already had its own data, so we signed in to that
/// instead of linking.
///
/// Reported separately because the uid changes: whatever was under the old
/// anonymous account is no longer what the app is reading.
class SignedInToExisting extends LinkOutcome {
  const SignedInToExisting(this.email);
  final String? email;
}

class LinkCancelled extends LinkOutcome {
  const LinkCancelled();
}

class LinkFailed extends LinkOutcome {
  const LinkFailed(this.message);
  final String message;
}

/// Attaches a real identity to the anonymous sync account.
///
/// An anonymous uid lives and dies with the app install, so on its own it
/// gives sync between sessions but no way to recover a backup after an
/// uninstall or a new phone. Linking is what makes it recoverable.
class AccountService {
  const AccountService();

  Future<LinkOutcome> linkGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;

      // Android resolves the server client id from google-services.json via
      // the generated `default_web_client_id` resource, so nothing needs to be
      // hardcoded here.
      await signIn.initialize();

      if (!signIn.supportsAuthenticate()) {
        return const LinkFailed(
          'Google sign-in is not available on this platform.',
        );
      }

      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return const LinkFailed('Google did not return a sign-in token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final auth = FirebaseAuth.instance;
      final current = auth.currentUser;

      if (current != null && current.isAnonymous) {
        try {
          final linked = await current.linkWithCredential(credential);
          return LinkedInPlace(linked.user?.email);
        } on FirebaseAuthException catch (e) {
          // The account already exists elsewhere — most likely this Google
          // account was linked on another device. Signing in to it is the
          // right move; silently discarding either side is not.
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            final result = await auth.signInWithCredential(credential);
            return SignedInToExisting(result.user?.email);
          }
          rethrow;
        }
      }

      final result = await auth.signInWithCredential(credential);
      return SignedInToExisting(result.user?.email);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const LinkCancelled();
      }
      return LinkFailed(_readable(e.code.name));
    } on FirebaseAuthException catch (e) {
      return LinkFailed(_readable(e.code));
    } catch (e) {
      return LinkFailed(_readable('$e'));
    }
  }

  /// Signs out of Firebase and Google.
  ///
  /// Local data is untouched — Drift is the source of truth and the app is
  /// fully usable signed out.
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Not being signed in to Google is not an error.
    }
    await FirebaseAuth.instance.signOut();
  }

  static String _readable(String code) {
    if (code.contains('network')) return "Couldn't reach Google.";
    if (code.contains('DEVELOPER_ERROR') || code.contains('10')) {
      // The single most common setup mistake, and the platform's own message
      // for it says nothing useful.
      return 'This build\'s signing key is not registered in Firebase. '
          'Add its SHA-1 fingerprint and download google-services.json again.';
    }
    return "Google sign-in didn't complete.";
  }
}
