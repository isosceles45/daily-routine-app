import 'package:daily_ritual/features/settings/providers/settings_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults are safe for a brand new install', () {
    const d = AppPreferences.defaults;
    expect(
      d.onboardingComplete,
      isFalse,
      reason: 'a fresh install must see onboarding',
    );
    expect(
      d.dailyReminders,
      isFalse,
      reason: 'never opt someone into notifications by default',
    );
    expect(d.allowDarkJokes, isTrue);
    expect(d.userName, isNotEmpty);
    expect(
      d.syncEnabled,
      isFalse,
      reason: 'onboarding promises nothing is uploaded, so sync starts off',
    );
  });

  test('copyWith changes only what it is given', () {
    const base = AppPreferences.defaults;
    final renamed = base.copyWith(userName: 'Atharva');

    expect(renamed.userName, 'Atharva');
    expect(renamed.allowDarkJokes, base.allowDarkJokes);
    expect(renamed.dailyReminders, base.dailyReminders);
    expect(renamed.onboardingComplete, base.onboardingComplete);
    expect(renamed.syncEnabled, base.syncEnabled);
  });

  test('flags can be turned off, not just on', () {
    // Guards against a copyWith written with `??` on a bool, where passing
    // false would silently keep the old value.
    const base = AppPreferences(
      userName: 'X',
      allowDarkJokes: true,
      dailyReminders: true,
      onboardingComplete: true,
      syncEnabled: true,
    );

    expect(base.copyWith(allowDarkJokes: false).allowDarkJokes, isFalse);
    expect(base.copyWith(dailyReminders: false).dailyReminders, isFalse);
    expect(
      base.copyWith(onboardingComplete: false).onboardingComplete,
      isFalse,
    );
    expect(base.copyWith(syncEnabled: false).syncEnabled, isFalse);
  });
}
