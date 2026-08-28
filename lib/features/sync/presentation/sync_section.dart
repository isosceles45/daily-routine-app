import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/account_service.dart';
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
          const SizedBox(height: 12),
          if (sync.isAnonymous)
            _LinkPrompt(onLink: () => _link(context, ref))
          else
            _LinkedAccount(
              email: sync.email,
              onSignOut: () => signOutOfSync(ref),
            ),
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

/// Runs the link and reports what actually happened.
///
/// The three outcomes are genuinely different and the user needs to know which
/// they got — especially signing in to an account that already had data, since
/// the uid changes underneath them.
Future<void> _link(BuildContext context, WidgetRef ref) async {
  final outcome = await linkGoogleAccount(ref);
  if (!context.mounted) return;

  final message = switch (outcome) {
    LinkedInPlace(:final email) =>
      'Backup linked to ${email ?? 'your Google account'}. It can be restored '
          'on another device now.',
    SignedInToExisting(:final email) =>
      'Signed in to ${email ?? 'that account'}, which already had a backup. '
          "You're now seeing its data.",
    LinkCancelled() => null,
    LinkFailed(:final message) => message,
  };

  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _LinkPrompt extends StatelessWidget {
  const _LinkPrompt({required this.onLink});

  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      padding: RitualShape.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: RitualColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                // Blunt on purpose: an anonymous account gives sync between
                // sessions, not recovery after an uninstall.
                child: Text(
                  'This backup is tied to this installation. Uninstall the app '
                  'and it cannot be recovered.',
                  style: RitualText.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Link a Google account',
            expand: false,
            onPressed: onLink,
          ),
        ],
      ),
    );
  }
}

class _LinkedAccount extends StatelessWidget {
  const _LinkedAccount({required this.email, required this.onSignOut});

  final String? email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      padding: RitualShape.cardPaddingCompact,
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 16,
            color: RitualColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recoverable',
                  style: outfit(size: 13, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  email ?? 'Linked to your Google account',
                  style: outfit(size: 12, color: RitualColors.textTertiary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSignOut,
            child: Text(
              'Sign out',
              style: outfit(size: 12, color: RitualColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
