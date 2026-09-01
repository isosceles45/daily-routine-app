import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/network/api_exception.dart';
import 'labels.dart';
import 'ritual_card.dart';
import 'ritual_button.dart';

/// Per-card failure state (§23).
///
/// One dead API must degrade exactly one card — never the page — so every
/// section renders this in place of its content and leaves its neighbours
/// untouched.
class ErrorCard extends StatelessWidget {
  const ErrorCard({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
    this.accent = RitualColors.textTertiary,
  });

  final String title;
  final Object error;
  final VoidCallback onRetry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;
    final message = api?.userMessage ?? "That didn't work.";
    final canRetry = api?.isRetryable ?? true;

    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(title, color: accent),
          const SizedBox(height: 10),
          Text(message, style: RitualText.bodySmall),
          if (canRetry) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: PrimaryButton(
                label: 'Retry',
                onPressed: onRetry,
                expand: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder shown while a card's content is in flight.
class LoadingCard extends StatelessWidget {
  const LoadingCard({
    super.key,
    required this.title,
    this.accent,
    this.lines = 2,
  });

  final String title;
  final Color? accent;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(title, color: accent ?? RitualColors.textTertiary),
          const SizedBox(height: 12),
          for (var i = 0; i < lines; i++) ...[
            _ShimmerBar(widthFactor: i.isEven ? 1.0 : 0.6),
            if (i != lines - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ShimmerBar extends StatefulWidget {
  const _ShimmerBar({required this.widthFactor});
  final double widthFactor;

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widget.widthFactor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          height: 12,
          decoration: BoxDecoration(
            color: Color.lerp(
              RitualColors.surfaceRaised,
              RitualColors.border,
              _controller.value,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
