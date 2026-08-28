import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// Preferences the user actually controls.
class AppPreferences {
  const AppPreferences({
    required this.userName,
    required this.allowDarkJokes,
    required this.dailyReminders,
    required this.onboardingComplete,
  });

  static const defaults = AppPreferences(
    userName: 'there',
    allowDarkJokes: true,
    dailyReminders: false,
    onboardingComplete: false,
  );

  /// Shown in the greeting and the Happy New Day screen.
  final String userName;

  /// When off, Saturday's dark joke is replaced by an ordinary one.
  final bool allowDarkJokes;

  /// Opt-in captured at onboarding. Notifications themselves arrive in
  /// Phase 4; this records the intent so nothing has to be asked twice.
  final bool dailyReminders;

  final bool onboardingComplete;

  AppPreferences copyWith({
    String? userName,
    bool? allowDarkJokes,
    bool? dailyReminders,
    bool? onboardingComplete,
  }) =>
      AppPreferences(
        userName: userName ?? this.userName,
        allowDarkJokes: allowDarkJokes ?? this.allowDarkJokes,
        dailyReminders: dailyReminders ?? this.dailyReminders,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class PreferencesNotifier extends AsyncNotifier<AppPreferences> {
  static const _nameKey = 'user_name';
  static const _darkJokesKey = 'allow_dark_jokes';
  static const _remindersKey = 'daily_reminders';
  static const _onboardedKey = 'onboarding_complete';

  @override
  Future<AppPreferences> build() async {
    final db = ref.watch(databaseProvider);

    Future<bool> flag(String key, {required bool fallback}) async {
      final value = await db.getSetting(key);
      return value == null ? fallback : value == 'true';
    }

    final name = await db.getSetting(_nameKey);

    return AppPreferences(
      userName: (name == null || name.trim().isEmpty)
          ? AppPreferences.defaults.userName
          : name.trim(),
      allowDarkJokes: await flag(_darkJokesKey, fallback: true),
      dailyReminders: await flag(_remindersKey, fallback: false),
      onboardingComplete: await flag(_onboardedKey, fallback: false),
    );
  }

  AppPreferences get _current => state.value ?? AppPreferences.defaults;

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await ref.read(databaseProvider).setSetting(_nameKey, trimmed);
    state = AsyncData(_current.copyWith(userName: trimmed));
  }

  Future<void> setAllowDarkJokes(bool allow) async {
    await ref.read(databaseProvider).setSetting(_darkJokesKey, '$allow');
    state = AsyncData(_current.copyWith(allowDarkJokes: allow));
  }

  Future<void> setDailyReminders(bool on) async {
    await ref.read(databaseProvider).setSetting(_remindersKey, '$on');
    state = AsyncData(_current.copyWith(dailyReminders: on));
  }

  /// Finishes onboarding in one write so a crash midway can't leave the app
  /// half-configured.
  Future<void> completeOnboarding({
    required String name,
    required bool allowDarkJokes,
    required bool dailyReminders,
  }) async {
    final db = ref.read(databaseProvider);
    final trimmed = name.trim();

    if (trimmed.isNotEmpty) await db.setSetting(_nameKey, trimmed);
    await db.setSetting(_darkJokesKey, '$allowDarkJokes');
    await db.setSetting(_remindersKey, '$dailyReminders');
    await db.setSetting(_onboardedKey, 'true');

    state = AsyncData(AppPreferences(
      userName: trimmed.isEmpty ? _current.userName : trimmed,
      allowDarkJokes: allowDarkJokes,
      dailyReminders: dailyReminders,
      onboardingComplete: true,
    ));
  }
}

final preferencesProvider =
    AsyncNotifierProvider<PreferencesNotifier, AppPreferences>(
  PreferencesNotifier.new,
);
