import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/sync_state.dart';
import '../providers/sync_providers.dart';

/// The Settings block for backup and sync.
///
/// Hidden entirely when Firebase isn't configured, rather than showing a
/// control that cannot work.
class SyncSection extends ConsumerWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(syncAvailableProvider)) return const SizedBox.shrink();

    final enabled = ref.watch(syncEnabledProvider);
    final sync = ref.watch(syncControllerProvider).value ?? SyncState.off;
    final controller = ref.read(syncControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Backup & sync'),
        const SizedBox(height: 6),
        _Toggle(
          label: 'Back up to the cloud',
          description: enabled
              ? 'Your days, todos and results are copied to your account.'
              : 'Off. Nothing leaves this device.',
          value: enabled,
          onChanged: (on) => on ? controller.enable() : controller.disable(),
        ),
        if (enabled) ...[
          const SizedBox(height: 12),
          _Status(state: sync),
          const SizedBox(height: 12),
          Row(
            children: [
              PrimaryButton(
                label: sync.phase == SyncPhase.running
                    ? 'Syncing…'
                    : 'Sync now',
                expand: false,
                onPressed: sync.phase == SyncPhase.running
                    ? null
                    : controller.syncNow,
              ),
            ],
          ),
          if (sync.isAnonymous) ...[
            const SizedBox(height: 12),
            RitualCard(
              padding: RitualShape.cardPaddingCompact,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: RitualColors.textTertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    // Worth being blunt about: an anonymous account is tied to
                    // this install. It gives sync, not recovery.
                    child: Text(
                      'This backup is tied to this installation. Uninstall the '
                      'app and it cannot be recovered. Signing in with Google '
                      'will make it restorable — that is coming next.',
                      style: RitualText.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final (icon, colour, text) = switch (state.phase) {
      SyncPhase.running => (Icons.sync, RitualColors.textSecondary, 'Syncing…'),
      SyncPhase.failed => (
        Icons.error_outline,
        RitualColors.error,
        state.message ?? "Sync didn't complete.",
      ),
      SyncPhase.signedOut => (
        Icons.cloud_off_rounded,
        RitualColors.textTertiary,
        'Not signed in yet.',
      ),
      SyncPhase.idle => (
        Icons.cloud_done_outlined,
        RitualColors.success,
        state.lastSyncedAt == null
            ? 'Ready.'
            : '${state.recordCount} record${state.recordCount == 1 ? '' : 's'} '
                  'synced at ${_time(state.lastSyncedAt!)}.',
      ),
      SyncPhase.off => (
        Icons.cloud_off_rounded,
        RitualColors.textTertiary,
        'Off.',
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colour),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: RitualText.bodySmall)),
      ],
    );
  }

  static String _time(DateTime at) =>
      '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: RitualColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: outfit(size: 14)),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: outfit(size: 12, color: RitualColors.textTertiary),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: RitualColors.onAccent,
              activeTrackColor: RitualColors.accent,
              inactiveThumbColor: RitualColors.textTertiary,
              inactiveTrackColor: RitualColors.surfaceRaised,
            ),
          ],
        ),
      ),
    );
  }
}
