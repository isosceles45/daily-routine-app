import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Visual state of a multiple-choice answer, straight from the canvas's
/// `optionView` helper.
enum OptionState {
  /// Not selected, question still open.
  idle,

  /// Selected but not yet submitted — 1.5px accent outline.
  selected,

  /// Revealed as the right answer — filled `--success`.
  correct,

  /// What the user picked, and it was wrong — `--error` outline and text.
  wrongChoice,

  /// A non-answer after submission — dimmed to `--text-tertiary`.
  dimmed,
}

/// One answer row. [letter] adds the A/B/C/D box the CAT screen uses; trivia
/// rows leave it null.
class OptionRow extends StatelessWidget {
  const OptionRow({
    super.key,
    required this.text,
    required this.state,
    this.letter,
    this.onTap,
  });

  final String text;
  final OptionState state;
  final String? letter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (state) {
      OptionState.idle => (RitualColors.surface, RitualColors.text, null),
      OptionState.selected => (
          RitualColors.surface,
          RitualColors.text,
          RitualColors.accent,
        ),
      OptionState.correct => (
          RitualColors.success,
          RitualColors.successOn,
          null,
        ),
      OptionState.wrongChoice => (
          RitualColors.surface,
          RitualColors.error,
          RitualColors.error,
        ),
      OptionState.dimmed => (
          RitualColors.surface,
          RitualColors.textTertiary,
          null,
        ),
    };

    final trailing = switch (state) {
      OptionState.correct => Icon(Icons.check, size: 16, color: foreground),
      OptionState.wrongChoice => Icon(Icons.close, size: 16, color: foreground),
      _ => null,
    };

    final row = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RitualShape.optionRadius),
        border: border == null
            ? Border.all(color: Colors.transparent, width: 1.5)
            : Border.all(color: border, width: 1.5),
      ),
      child: Row(
        children: [
          if (letter != null) ...[
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RitualShape.chipRadius),
                border: Border.all(
                  color: state == OptionState.idle ||
                          state == OptionState.selected
                      ? RitualColors.borderStrong
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                letter!,
                style: outfit(
                    size: 11, weight: FontWeight.w800, color: foreground),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: outfit(size: 14, color: foreground, height: 1.35),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );

    // Once answered the row is inert — the canvas switches the cursor to
    // `default`, and re-answering would corrupt the day's saved result.
    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RitualShape.optionRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RitualShape.optionRadius),
        child: row,
      ),
    );
  }
}
