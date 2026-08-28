import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_providers.dart';

import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Turns reminders on or off, asking for permission the first time.
///
/// Returns false when the user declined, so the caller can put the switch
/// back rather than leaving it showing a state the OS has overruled.
Future<bool> setRemindersEnabled(WidgetRef ref, bool enabled) async {
  final service = ref.read(notificationServiceProvider);

  if (!enabled) {
    await service.setDailyGreeting(enabled: false);
    await ref.read(preferencesProvider.notifier).setDailyReminders(false);
    return true;
  }

  final granted = await service.requestPermission();
  if (!granted) return false;

  await service.setDailyGreeting(enabled: true);
  await ref.read(preferencesProvider.notifier).setDailyReminders(true);
  return true;
}

/// Re-applies the saved preference at startup.
///
/// Android drops scheduled alarms on reboot and on app updates, so the
/// schedule is rebuilt every launch rather than assumed to still exist.
final notificationBootstrapProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(preferencesProvider.future);
  final service = ref.read(notificationServiceProvider);

  await service.initialise();
  await service.setDailyGreeting(enabled: prefs.dailyReminders);
});
