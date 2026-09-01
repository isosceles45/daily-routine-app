import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/game_kind.dart';
import '../domain/quant_rush.dart';
import '../providers/game_providers.dart';

/// A 60-second mental-arithmetic sprint.
class QuantRushScreen extends ConsumerStatefulWidget {
  const QuantRushScreen({super.key});

  @override
  ConsumerState<QuantRushScreen> createState() => _QuantRushScreenState();
}

enum _Phase { ready, running, over }

class _QuantRushScreenState extends ConsumerState<QuantRushScreen> {
  final _rng = Random();

  _Phase _phase = _Phase.ready;
  late QuantRound _round;
  Timer? _ticker;
  int _remaining = QuantRush.duration.inSeconds;

  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;

  /// Set briefly after an answer so the option can flash right or wrong.
  int? _judged;
  bool _judgedCorrect = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _phase = _Phase.running;
      _remaining = QuantRush.duration.inSeconds;
      _correct = 0;
      _wrong = 0;
      _streak = 0;
      _bestStreak = 0;
      _judged = null;
      _round = QuantRush.next(_rng);
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) _finish();
    });
  }

  Future<void> _finish() async {
    _ticker?.cancel();
    setState(() => _phase = _Phase.over);

    await ref
        .read(gameRepositoryProvider)
        .recordScore(
          game: GameKind.quantRush,
          score: _correct,
          date: ref.read(currentDateProvider),
          detail: {
            'wrong': _wrong,
            'bestStreak': _bestStreak,
            'seconds': QuantRush.duration.inSeconds,
          },
        );
  }

  void _answer(int index) {
    if (_phase != _Phase.running || _judged != null) return;

    final right = _round.isCorrect(index);
    setState(() {
      _judged = index;
      _judgedCorrect = right;
      if (right) {
        _correct++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _wrong++;
        _streak = 0;
      }
    });

    // A beat of feedback, then straight on — the pace is the game.
    Timer(const Duration(milliseconds: 220), () {
      if (!mounted || _phase != _Phase.running) return;
      setState(() {
        _judged = null;
        _round = QuantRush.next(_rng);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Quant Rush',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: switch (_phase) {
          _Phase.ready => _Intro(onStart: _start),
          _Phase.running => _Playing(
            round: _round,
            remaining: _remaining,
            correct: _correct,
            streak: _streak,
            judged: _judged,
            judgedCorrect: _judgedCorrect,
            onAnswer: _answer,
          ),
          _Phase.over => _Result(
            correct: _correct,
            wrong: _wrong,
            bestStreak: _bestStreak,
            onAgain: _start,
          ),
        },
      ),
    );
  }
}

class _Intro extends ConsumerWidget {
  const _Intro({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final best = ref.watch(gameStatsProvider)[GameKind.quantRush]?.best;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RitualIcon(
          RitualIcons.bolt,
          size: 42,
          color: RitualColors.accent,
        ),
        const SizedBox(height: 14),
        Text('60 seconds', style: RitualText.stat(30)),
        const SizedBox(height: 8),
        Text(
          'As many as you can. Multiplication, percentages, squares, '
          'fractions, averages — the same maths the CAT card drills, at speed.',
          style: RitualText.bodySmall,
        ),
        if (best != null) ...[
          const SizedBox(height: 14),
          Text(
            'Your best: $best correct',
            style: outfit(
              size: 13,
              weight: FontWeight.w800,
              color: RitualColors.accent,
            ),
          ),
        ],
        const SizedBox(height: 26),
        PrimaryButton(label: 'Start', onPressed: onStart),
      ],
    );
  }
}

class _Playing extends StatelessWidget {
  const _Playing({
    required this.round,
    required this.remaining,
    required this.correct,
    required this.streak,
    required this.judged,
    required this.judgedCorrect,
    required this.onAnswer,
  });

  final QuantRound round;
  final int remaining;
  final int correct;
  final int streak;
  final int? judged;
  final bool judgedCorrect;
  final void Function(int) onAnswer;

  @override
  Widget build(BuildContext context) {
    // The last ten seconds are the only ones anyone looks at.
    final urgent = remaining <= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Eyebrow(
              round.topic,
              color: RitualColors.accent,
              letterSpacing: 0.1,
            ),
            const Spacer(),
            Text(
              '0:${remaining.clamp(0, 99).toString().padLeft(2, '0')}',
              style: outfit(
                size: 17,
                weight: FontWeight.w800,
                color: urgent ? RitualColors.error : RitualColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: remaining / QuantRush.duration.inSeconds,
          minHeight: 3,
          backgroundColor: RitualColors.border,
          valueColor: AlwaysStoppedAnimation(
            urgent ? RitualColors.error : RitualColors.accent,
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Text(
            round.prompt,
            textAlign: TextAlign.center,
            style: RitualText.stat(34),
          ),
        ),
        const SizedBox(height: 36),
        for (var i = 0; i < round.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerButton(
              label: round.options[i],
              state: judged == null
                  ? _AnswerState.idle
                  : judged == i
                  ? (judgedCorrect ? _AnswerState.right : _AnswerState.wrong)
                  : _AnswerState.idle,
              onTap: () => onAnswer(i),
            ),
          ),
        // Not a Spacer: this sits inside DetailScaffold's scroll view, where
        // there is no bounded height for one to expand into.
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$correct correct',
              style: outfit(size: 13, color: RitualColors.textSecondary),
            ),
            if (streak >= 3)
              Row(
                children: [
                  const RitualIcon(
                    RitualIcons.flame,
                    size: 14,
                    color: RitualColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$streak in a row',
                    style: outfit(
                      size: 13,
                      weight: FontWeight.w800,
                      color: RitualColors.accent,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

enum _AnswerState { idle, right, wrong }

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, text) = switch (state) {
      _AnswerState.idle => (
        RitualColors.surface,
        RitualColors.border,
        RitualColors.text,
      ),
      _AnswerState.right => (
        RitualColors.successOn,
        RitualColors.success,
        RitualColors.success,
      ),
      _AnswerState.wrong => (
        RitualColors.accentSoft,
        RitualColors.error,
        RitualColors.error,
      ),
    };

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RitualShape.buttonRadius),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: outfit(size: 17, weight: FontWeight.w800, color: text),
          ),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({
    required this.correct,
    required this.wrong,
    required this.bestStreak,
    required this.onAgain,
  });

  final int correct;
  final int wrong;
  final int bestStreak;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final best = ref.watch(gameStatsProvider)[GameKind.quantRush]?.best ?? 0;
    final isRecord = correct >= best && correct > 0;
    final attempted = correct + wrong;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRecord)
          Eyebrow(
            'New personal best',
            color: RitualColors.success,
            letterSpacing: 0.12,
          ),
        const SizedBox(height: 6),
        Text('$correct correct', style: RitualText.stat(34)),
        const SizedBox(height: 8),
        Text(
          attempted == 0
              ? 'Nothing attempted.'
              : '$attempted attempted · '
                    '${(correct / attempted * 100).round()}% accuracy · '
                    'best run $bestStreak',
          style: RitualText.bodySmall,
        ),
        const SizedBox(height: 26),
        PrimaryButton(label: 'Again', onPressed: onAgain),
      ],
    );
  }
}
