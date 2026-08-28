import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/trivia_question.dart';
import '../providers/trivia_providers.dart';

class TriviaScreen extends ConsumerStatefulWidget {
  const TriviaScreen({super.key});

  @override
  ConsumerState<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends ConsumerState<TriviaScreen> {
  String? _selected;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final trivia = ref.watch(dailyTriviaProvider);
    final saved = ref.watch(triviaResultProvider).value;
    final accent = context.features.trivia;

    return DetailScaffold(
      title: 'Daily Trivia',
      child: trivia.when(
        loading: () => LoadingCard(title: 'Daily Trivia', accent: accent),
        error: (error, _) => ErrorCard(
          title: 'Daily Trivia',
          error: error,
          accent: accent,
          onRetry: () => ref.invalidate(dailyTriviaProvider),
        ),
        data: (question) => _Question(
          question: question,
          accent: accent,
          // A saved answer wins over local selection, so reopening the screen
          // shows the resolved state rather than an open question.
          submittedAnswer: saved?.answered == true
              ? saved!.selectedAnswer
              : null,
          selected: _selected,
          submitting: _submitting,
          onSelect: (answer) => setState(() => _selected = answer),
          onSubmit: () async {
            final answer = _selected;
            if (answer == null) return;
            setState(() => _submitting = true);
            await answerTrivia(ref, answer);
            if (mounted) setState(() => _submitting = false);
          },
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.accent,
    required this.submittedAnswer,
    required this.selected,
    required this.submitting,
    required this.onSelect,
    required this.onSubmit,
  });

  final TriviaQuestion question;
  final Color accent;
  final String? submittedAnswer;
  final String? selected;
  final bool submitting;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onSubmit;

  bool get _answered => submittedAnswer != null;

  @override
  Widget build(BuildContext context) {
    final correct = _answered && submittedAnswer == question.correctAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FeatureChip(question.category, color: accent),
            const SizedBox(width: 8),
            FeatureChip(question.difficulty),
          ],
        ),
        const SizedBox(height: 16),
        Text(question.question, style: RitualText.questionStem),
        const SizedBox(height: 16),
        for (final answer in question.answers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OptionRow(
              text: answer,
              state: _stateFor(answer),
              onTap: _answered ? null : () => onSelect(answer),
            ),
          ),
        if (!_answered) ...[
          const SizedBox(height: 6),
          PrimaryButton(
            label: submitting ? 'Saving…' : 'Submit',
            onPressed: selected == null || submitting ? null : onSubmit,
          ),
        ] else ...[
          const SizedBox(height: 6),
          PopIn(
            // Column is start-aligned for the chips and stem, so the result
            // card needs its width stated or it shrinks to fit its text.
            child: SizedBox(
              width: double.infinity,
              child: RitualCard(
                padding: RitualShape.cardPaddingCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct ? 'Correct!' : 'Not quite',
                      style: outfit(
                        size: 16,
                        weight: FontWeight.w800,
                        color: correct
                            ? RitualColors.success
                            : RitualColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // OpenTDB supplies no explanation, and inventing one would
                    // break the same rule the CAT feature follows: never show an
                    // answer the source didn't stand behind. So we state the
                    // answer and stop there.
                    Text(
                      'The answer was ${question.correctAnswer}.',
                      style: RitualText.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Source: ${question.source}',
                      style: outfit(size: 11, color: RitualColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  OptionState _stateFor(String answer) {
    if (!_answered) {
      return answer == selected ? OptionState.selected : OptionState.idle;
    }
    if (answer == question.correctAnswer) return OptionState.correct;
    if (answer == submittedAnswer) return OptionState.wrongChoice;
    return OptionState.dimmed;
  }
}
