import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/surprise_pack.dart';
import '../providers/surprise_providers.dart';

/// Surprise Me.
///
/// Explore is a library: persistent, one item per category, each opening its
/// own screen. A surprise is a *moment* — random, disposable, and meant to read
/// as one thing you pulled rather than five things to browse. Rendering it as a
/// stack of sibling cards made it indistinguishable from Explore, so the pack
/// is composed instead: a full-bleed hero, the rest as rows inside a single
/// surface, and the challenge as that surface's footer.
class SurpriseScreen extends ConsumerStatefulWidget {
  const SurpriseScreen({super.key, this.autoRoll = false});

  /// Set when arriving from the Today band, which is a roll action — its own
  /// label says "give me something unexpected", so it gives one.
  final bool autoRoll;

  @override
  ConsumerState<SurpriseScreen> createState() => _SurpriseScreenState();
}

class _SurpriseScreenState extends ConsumerState<SurpriseScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoRoll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(surpriseProvider.notifier).roll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final surprise = ref.watch(surpriseProvider);

    return DetailScaffold(
      title: 'Surprise Me',
      padding: EdgeInsets.zero,
      child: surprise.when(
        loading: () => const _Assembling(),
        error: (error, _) => Padding(
          padding: RitualShape.screenPadding,
          child: ErrorCard(
            title: 'Surprise',
            error: error,
            accent: RitualColors.accent,
            onRetry: () => ref.read(surpriseProvider.notifier).roll(),
          ),
        ),
        data: (pack) => pack == null ? const _FirstRun() : _Pack(pack: pack),
      ),
    );
  }
}

class _FirstRun extends ConsumerWidget {
  const _FirstRun();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: RitualShape.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Center(
            child: Icon(
              Icons.auto_awesome,
              size: 44,
              color: RitualColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pull something\nunexpected.',
            textAlign: TextAlign.center,
            style: RitualText.greeting,
          ),
          const SizedBox(height: 12),
          Text(
            'Five corners of the internet, assembled into one pack. '
            "Nothing here is today's official content — roll as often as you "
            'like and your day stays exactly as it was.',
            textAlign: TextAlign.center,
            style: RitualText.bodySmall,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Surprise me',
            trailingArrow: true,
            onPressed: () => ref.read(surpriseProvider.notifier).roll(),
          ),
        ],
      ),
    );
  }
}

class _Assembling extends StatelessWidget {
  const _Assembling();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 260, color: RitualColors.surfaceRaised),
        Padding(
          padding: RitualShape.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('Assembling your pack', color: RitualColors.accent),
              const SizedBox(height: 16),
              LoadingCard(title: '', accent: RitualColors.accent, lines: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pack extends ConsumerWidget {
  const _Pack({required this.pack});

  final SurprisePack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(surpriseCountProvider).value ?? 1;

    // The first slot carrying a photo becomes the hero; everything else
    // becomes a row, so the pack has a focal point instead of five equals.
    final hero = pack.slots.where((s) => s.imageUrl != null).firstOrNull;
    final rows = pack.slots.where((s) => s != hero).toList(growable: false);

    return PopIn(
      key: ValueKey('${pack.challenge}$count'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hero != null) _Hero(slot: hero, index: count),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hero == null) ...[
                  _PackLabel(index: count),
                  const SizedBox(height: 16),
                ],
                // One surface, divided rows — the pack reads as a single
                // object rather than a scrollable list of them.
                RitualCard(
                  padding: EdgeInsets.zero,
                  clipContents: true,
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        _Row(slot: rows[i]),
                        if (i != rows.length - 1)
                          const RitualDivider(strong: false),
                      ],
                      _ChallengeFooter(text: pack.challenge),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Another surprise',
                  trailingArrow: true,
                  onPressed: () => ref.read(surpriseProvider.notifier).roll(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed image with the label and value laid over a scrim.
class _Hero extends StatelessWidget {
  const _Hero({required this.slot, required this.index});

  final SurpriseSlot slot;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: slot.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: RitualColors.surfaceRaised),
            errorWidget: (_, _, _) =>
                Container(color: RitualColors.surfaceRaised),
          ),
          // Scrim so the text stays readable over any photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0xCC14131A),
                  Color(0xFF14131A),
                ],
                stops: [0.35, 0.78, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PackLabel(index: index),
                const SizedBox(height: 10),
                Eyebrow(slot.label, color: RitualColors.accent, size: 10),
                const SizedBox(height: 4),
                Text(
                  slot.value,
                  style: outfit(
                    size: 28,
                    weight: FontWeight.w800,
                    letterSpacing: -0.015,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackLabel extends StatelessWidget {
  const _PackLabel({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, size: 14, color: RitualColors.accent),
        const SizedBox(width: 6),
        Eyebrow(
          index <= 1 ? 'Your pack' : 'Pack no. $index',
          color: RitualColors.accent,
          size: 10,
          letterSpacing: 0.12,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.slot});

  final SurpriseSlot slot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slot.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: slot.imageUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 44,
                  height: 44,
                  color: RitualColors.surfaceRaised,
                ),
                errorWidget: (_, _, _) => Container(
                  width: 44,
                  height: 44,
                  color: RitualColors.surfaceRaised,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(slot.label, size: 10, letterSpacing: 0.1),
                const SizedBox(height: 4),
                Text(slot.value, style: outfit(size: 14, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The challenge closes the pack rather than sitting beside it.
class _ChallengeFooter extends StatelessWidget {
  const _ChallengeFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: RitualColors.accent,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR CHALLENGE',
            style: outfit(
              size: 10,
              weight: FontWeight.w800,
              color: RitualColors.onAccent,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: outfit(size: 14, color: RitualColors.onAccent, height: 1.5),
          ),
        ],
      ),
    );
  }
}
