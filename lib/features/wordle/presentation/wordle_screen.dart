import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/database/database.dart';
import '../../../core/network/api_sources.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../providers/wordle_providers.dart';
import '../domain/wordle_share.dart';
import 'wordle_board.dart';
import 'wordle_distribution.dart';
import 'wordle_import_sheet.dart';

/// Opens the official Wordle page inside the app (§6, §27).
///
/// `inAppBrowserView` is a Chrome Custom Tab on Android and an
/// `SFSafariViewController` on iOS. Both render the real NYT page — nothing is
/// scraped or reimplemented — while keeping Ritual on the back stack, so
/// finishing the puzzle and returning to paste the result is one gesture
/// rather than an app switch.
///
/// Both also share cookies with the user's default browser, so an existing NYT
/// login and its streak carry over. That is *not* true of `inAppWebView`, which
/// gets an isolated cookie jar and would silently sign the user out.
Future<bool> openWordle() async {
  final url = Uri.parse(ApiSources.wordle);

  final opened = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  if (opened) return true;

  // No Custom Tabs provider installed — fall back rather than fail.
  return launchUrl(url, mode: LaunchMode.externalApplication);
}

class WordleScreen extends ConsumerStatefulWidget {
  const WordleScreen({super.key, this.autoPlay = false});

  /// Set when the user tapped "Play Wordle" on Today. The button said it would
  /// open Wordle, so it opens Wordle — landing here first and asking again was
  /// a tap that did nothing.
  final bool autoPlay;

  @override
  ConsumerState<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends ConsumerState<WordleScreen>
    with WidgetsBindingObserver {
  /// True between opening the puzzle and coming back, so the clipboard is only
  /// inspected when the user has actually been to Wordle — not every time the
  /// app happens to resume.
  bool _awaitingReturn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.autoPlay) {
      // After the first frame, so the screen is mounted underneath and the
      // user returns to stats and the import sheet rather than a blank route.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _play();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingReturn) {
      _awaitingReturn = false;
      _offerClipboardImport();
    }
  }

  /// Closes the loop from §6: play, Share, come back, paste.
  ///
  /// Opening the sheet unprompted is only defensible because we know the user
  /// just came back from Wordle *and* the clipboard genuinely holds a share
  /// they haven't already saved. Anything less certain stays silent.
  Future<void> _offerClipboardImport() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;

    final share = WordleShareParser.parse(text);
    if (share == null) return;

    final existing = await ref
        .read(wordleRepositoryProvider)
        .forDate(share.date);
    if (existing != null && existing.score == share.score) return;
    if (!mounted) return;

    await showWordleImportSheet(context);
  }

  Future<void> _play() async {
    _awaitingReturn = true;
    final launched = await openWordle();
    if (launched) return;

    _awaitingReturn = false;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Couldn't open a browser for Wordle.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(todayWordleProvider).value;
    final stats = ref.watch(wordleStatsProvider);
    final number = ref.watch(todayWordleNumberProvider);

    return DetailScaffold(
      title: 'Wordle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Eyebrow('Puzzle #$number', color: RitualColors.accent),
              if (result?.hardMode ?? false)
                const FeatureChip('Hard mode', color: RitualColors.accent),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: WordleBoard(
              rows: result?.grid?.split('\n') ?? const [],
              tileSize: 46,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _statusLine(result),
              style: RitualText.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Play Wordle',
            trailingArrow: true,
            onPressed: _play,
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            label: result == null ? 'Paste result' : 'Replace result',
            icon: Icons.content_paste_rounded,
            onPressed: () => showWordleImportSheet(context),
          ),
          const SizedBox(height: 26),
          const RitualDivider(),
          const SizedBox(height: 20),
          Eyebrow('Your Wordle'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatBlock(value: '${stats.currentStreak}', label: 'Streak'),
              StatBlock(value: '${stats.longestStreak}', label: 'Longest'),
              StatBlock(value: stats.averageLabel, label: 'Average'),
              StatBlock(value: '${stats.total}', label: 'Games'),
            ],
          ),
          if (stats.total > 0) ...[
            const SizedBox(height: 22),
            Eyebrow('Guess distribution'),
            const SizedBox(height: 12),
            WordleDistribution(stats: stats),
          ],
        ],
      ),
    );
  }

  String _statusLine(WordleResult? result) {
    if (result == null) return "Today's puzzle is waiting.";
    if (!result.completed) return "You didn't get this one — X/6.";
    return 'Solved in ${result.score}/6.';
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: RitualColors.borderStrong, width: 1.5),
            borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: RitualColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: outfit(
                  size: 13,
                  weight: FontWeight.w800,
                  color: RitualColors.textSecondary,
                  letterSpacing: 0.04,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
