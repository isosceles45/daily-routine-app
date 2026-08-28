import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../data/cat_repository.dart';
import '../domain/cat_question.dart';
import '../providers/cat_providers.dart';

class CatScreen extends ConsumerStatefulWidget {
  const CatScreen({super.key});

  @override
  ConsumerState<CatScreen> createState() => _CatScreenState();
}

class _CatScreenState extends ConsumerState<CatScreen> {
  int? _selected;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final question = ref.watch(catQuestionProvider);
    final saved = ref.watch(catResultProvider).value;
    final accent = context.features.catQuant;

    return DetailScaffold(
      title: 'CAT Quant',
      child: question.when(
        loading: () => LoadingCard(title: 'CAT Quant', accent: accent, lines: 3),
        error: (error, _) => ErrorCard(
          title: 'CAT Quant',
          error: error,
          accent: accent,
          onRetry: () => retryCatQuestion(ref),
        ),
        data: (data) {
          // Every tier came up empty. The spec is explicit: show this rather
          // than a fabricated question (§8).
          if (data == null) return _Unavailable(accent: accent);

          return _Question(
            question: data,
            accent: accent,
            accuracy: ref.watch(catAccuracyProvider),
            submittedIndex: saved?.answered == true ? saved!.selectedIndex : null,
            selected: _selected,
            submitting: _submitting,
            onSelect: (i) => setState(() => _selected = i),
            onSubmit: () async {
              final index = _selected;
              if (index == null) return;
              setState(() => _submitting = true);
              await answerCatQuestion(ref, index);
              if (mounted) setState(() => _submitting = false);
            },
          );
        },
      ),
    );
  }
}

class _Unavailable extends ConsumerWidget {
  const _Unavailable({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RitualCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('CAT Quant', color: accent),
          const SizedBox(height: 12),
          Text(
            "Today's question isn't available yet.",
            style: outfit(size: 16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Nothing verified came back, and a question whose answer '
            "hasn't been checked isn't worth answering.",
            style: RitualText.bodySmall,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(
              label: 'Try again',
              expand: false,
              onPressed: () => retryCatQuestion(ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.accent,
    required this.accuracy,
    required this.submittedIndex,
    required this.selected,
    required this.submitting,
    required this.onSelect,
    required this.onSubmit,
  });

  final CatQuestion question;
  final Color accent;
  final CatAccuracy accuracy;
  final int? submittedIndex;
  final int? selected;
  final bool submitting;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onSubmit;

  bool get _answered => submittedIndex != null;

  @override
  Widget build(BuildContext context) {
    final correct = _answered && question.isCorrect(submittedIndex!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FeatureChip(question.difficulty, color: accent),
            const SizedBox(width: 8),
            Flexible(child: FeatureChip(question.topic)),
          ],
        ),
        const SizedBox(height: 16),
        Text(question.stem, style: RitualText.questionStemSmall),
        const SizedBox(height: 18),
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OptionRow(
              text: question.options[i],
              letter: CatQuestion.letterFor(i),
              state: _stateFor(i),
              onTap: _answered ? null : () => onSelect(i),
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
            child: SizedBox(
              width: double.infinity,
              child: RitualCard(
                padding: RitualShape.cardPaddingCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          correct ? 'Correct' : 'Incorrect',
                          style: outfit(
                            size: 16,
                            weight: FontWeight.w800,
                            color: correct
                                ? RitualColors.success
                                : RitualColors.error,
                          ),
                        ),
                        // The canvas showed a global "26% solved this"; that
                        // needs a backend we don't have, so this is the
                        // honest local equivalent.
                        Flexible(
                          child: Text(
                            accuracy.label,
                            textAlign: TextAlign.right,
                            style: outfit(
                                size: 12, color: RitualColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                    if (question.solution != null) ...[
                      const SizedBox(height: 12),
                      const RitualDivider(strong: false),
                      const SizedBox(height: 12),
                      Eyebrow('Quick solution', letterSpacing: 0.08),
                      const SizedBox(height: 8),
                      Text(
                        question.solution!,
                        style: outfit(
                          size: 13,
                          color: RitualColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      '${question.source.label} · ${question.verification.label}',
                      style: outfit(
                          size: 11, color: RitualColors.textTertiary),
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

  OptionState _stateFor(int index) {
    if (!_answered) {
      return index == selected ? OptionState.selected : OptionState.idle;
    }
    if (index == question.answerIndex) return OptionState.correct;
    if (index == submittedIndex) return OptionState.wrongChoice;
    return OptionState.dimmed;
  }
}
