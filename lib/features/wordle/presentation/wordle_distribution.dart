import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../domain/wordle_stats.dart';

/// The 1–6 guess distribution from the canvas: a label, a bar scaled to the
/// tallest row, and the count. The modal row is drawn in accent.
class WordleDistribution extends StatelessWidget {
  const WordleDistribution({super.key, required this.stats});

  final WordleStats stats;

  @override
  Widget build(BuildContext context) {
    final peak = stats.distributionPeak;

    return Column(
      children: [
        for (var guesses = 1; guesses <= 6; guesses++) ...[
          _Row(
            guesses: guesses,
            count: stats.distribution[guesses] ?? 0,
            peak: peak,
          ),
          if (guesses != 6) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.guesses, required this.count, required this.peak});

  final int guesses;
  final int count;
  final int peak;

  @override
  Widget build(BuildContext context) {
    // An empty row still shows a sliver, so the axis reads as a scale rather
    // than a gap.
    final fraction = peak == 0 ? 0.0 : count / peak;
    final isPeak = count > 0 && count == peak;

    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            '$guesses',
            style: outfit(
              size: 12,
              weight: FontWeight.w700,
              color: RitualColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: RitualColors.surface,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isPeak
                      ? RitualColors.accent
                      : RitualColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: outfit(
              size: 12,
              weight: FontWeight.w700,
              color: RitualColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
