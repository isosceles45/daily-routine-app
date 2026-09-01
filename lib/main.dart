import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/theme.dart';
import 'core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sync is opt-in, but Firebase has to be up before Settings can offer it.
  // A failure here is not fatal: the app is local-first and works with no
  // backend at all.
  final firebaseReady = await initialiseFirebase();

  // The design is a dark app edge to edge; let content run under the system
  // bars and draw their icons light.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: RitualColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const DailyRitualApp(),
    ),
  );
}
