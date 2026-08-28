import 'package:daily_ritual/core/notifications/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  });

  test('the greeting is scheduled for midnight', () {
    // §16: the greeting marks the new day, so it belongs at 00:00.
    expect(NotificationService.greetingHour, 0);
  });

  test('the next occurrence lands on the hour, in the future', () {
    final next = NotificationService.nextInstanceOf(
      NotificationService.greetingHour,
    );

    expect(next.hour, 0);
    expect(next.minute, 0);
    expect(next.isAfter(tz.TZDateTime.now(tz.local)), isTrue,
        reason: 'a schedule in the past would fire immediately');
  });

  test('it is always within a day', () {
    final now = tz.TZDateTime.now(tz.local);
    final next = NotificationService.nextInstanceOf(0);
    expect(next.difference(now).inHours, lessThanOrEqualTo(24));
  });

  test('todo notification ids are stable and distinct from the greeting', () {
    expect(NotificationIds.forTodo('abc'), NotificationIds.forTodo('abc'));
    expect(NotificationIds.forTodo('abc'),
        isNot(NotificationIds.forTodo('xyz')));
    expect(NotificationIds.forTodo('abc'),
        isNot(NotificationIds.dailyGreeting));
    expect(NotificationIds.forTodo('abc'), greaterThan(999));
  });
}
