import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notification ids. Fixed so rescheduling replaces rather than duplicates.
abstract final class NotificationIds {
  static const dailyGreeting = 1;

  /// Todo reminders derive an id from the todo's own id, offset well clear of
  /// the fixed ones.
  static int forTodo(String todoId) => 1000 + (todoId.hashCode.abs() % 100000);
}

/// Wraps local notifications behind something the rest of the app can call
/// without knowing whether the platform supports them (§16, §27).
///
/// Every method is safe to call when notifications are unavailable or denied —
/// it does nothing rather than throwing.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _channelId = 'daily_ritual';
  static const _channelName = 'Ritual';
  static const _channelDescription =
      'Your new day, and reminders you asked for.';

  /// Midnight, when the new day actually starts (§16).
  static const greetingHour = 0;

  Future<void> initialise() async {
    if (_ready) return;

    try {
      tz_data.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_ritual'),
          iOS: DarwinInitializationSettings(
            // Asked for explicitly when the user enables reminders, not on
            // first launch — a permission prompt with no context gets denied.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      _ready = true;
    } catch (error) {
      debugPrint('Notifications unavailable: $error');
    }
  }

  /// Asks the platform for permission. Returns false if denied or unsupported.
  Future<bool> requestPermission() async {
    await initialise();
    if (!_ready) return false;

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (error) {
      debugPrint('Notification permission request failed: $error');
    }
    return false;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Schedules the daily greeting, or cancels it when [enabled] is false.
  Future<void> setDailyGreeting({required bool enabled}) async {
    await initialise();
    if (!_ready) return;

    try {
      await _plugin.cancel(id: NotificationIds.dailyGreeting);
      if (!enabled) return;

      await _plugin.zonedSchedule(
        id: NotificationIds.dailyGreeting,
        title: 'Happy New Day',
        body: 'Your ritual is ready.',
        scheduledDate: _nextInstanceOf(greetingHour),
        notificationDetails: _details,
        // Exact, because "the new day has started" is only true at midnight —
        // an inexact alarm can drift by an hour or more under Doze, which
        // would land it in the middle of the night for no reason.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Repeats daily at the same clock time.
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      debugPrint('Could not schedule the daily greeting: $error');
    }
  }

  /// Schedules a reminder for one todo. Past times are ignored rather than
  /// firing immediately.
  Future<void> setTodoReminder({
    required String todoId,
    required String title,
    required DateTime? at,
  }) async {
    await initialise();
    if (!_ready) return;

    final id = NotificationIds.forTodo(todoId);

    try {
      await _plugin.cancel(id: id);
      if (at == null || at.isBefore(DateTime.now())) return;

      await _plugin.zonedSchedule(
        id: id,
        title: 'Todo reminder',
        body: title,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('Could not schedule a todo reminder: $error');
    }
  }

  Future<void> cancelTodoReminder(String todoId) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: NotificationIds.forTodo(todoId));
    } catch (_) {
      // Cancelling something never scheduled is not an error.
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  /// The next time [hour] comes around in the device's own timezone — today if
  /// it hasn't passed, otherwise tomorrow.
  static tz.TZDateTime nextInstanceOf(int hour) => _nextInstanceOf(hour);

  static tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }
}
