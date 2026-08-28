import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/database.dart';
import 'dates/daily_date_service.dart';
import 'maintenance.dart';
import 'notifications/notification_providers.dart';
import 'network/api_client.dart';

/// Long-lived singletons. Everything downstream reads these rather than
/// constructing its own Dio or database handle.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

final dailyDateServiceProvider = Provider<DailyDateService>(
  (ref) => const DailyDateService(),
);

/// Today's local calendar date as `yyyy-MM-dd`.
///
/// Everything daily keys off this single value, so a rollover invalidates the
/// whole tree at once rather than each feature noticing separately.
class CurrentDateNotifier extends Notifier<String> {
  @override
  String build() => ref.read(dailyDateServiceProvider).today();

  /// Re-reads the clock. Called on cold start and whenever the app returns to
  /// the foreground — the app must never depend on being open at midnight (§3).
  ///
  /// Returns true when the date actually changed.
  bool refresh() {
    final today = ref.read(dailyDateServiceProvider).today();
    if (today == state) return false;
    state = today;
    return true;
  }
}

final currentDateProvider = NotifierProvider<CurrentDateNotifier, String>(
  CurrentDateNotifier.new,
);

/// True on the first of the month — the day the app celebrates loudly.
final isFirstOfMonthProvider = Provider<bool>((ref) {
  final date = ref.watch(currentDateProvider);
  return DailyDateService.parse(date).day == 1;
});

/// Ensures a `daily_states` row exists for today and exposes it.
final dailyStateProvider = FutureProvider<DailyState>((ref) async {
  final date = ref.watch(currentDateProvider);
  final db = ref.watch(databaseProvider);
  return db.ensureDay(date);
});

/// Watches app lifecycle and refreshes the date when we come back to the
/// foreground, so closing at 23:50 and reopening at 08:00 starts a new day.
class DailyRolloverObserver extends ConsumerStatefulWidget {
  const DailyRolloverObserver({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DailyRolloverObserver> createState() =>
      _DailyRolloverObserverState();
}

class _DailyRolloverObserverState extends ConsumerState<DailyRolloverObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Fire-and-forget: neither of these may delay first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(maintenanceProvider);
      // Android drops scheduled alarms on reboot and on app update, so the
      // schedule is rebuilt each launch rather than assumed to survive.
      ref.read(notificationBootstrapProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(currentDateProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
