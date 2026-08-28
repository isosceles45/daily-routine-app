import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/dates/daily_date_service.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../wordle/presentation/wordle_board.dart';
import '../../cat_quant/providers/cat_providers.dart';
import '../../todos/providers/todo_providers.dart';
import '../../trivia/providers/trivia_providers.dart';
import '../../wordle/providers/wordle_providers.dart';
import '../providers/completion_providers.dart';
import '../providers/history_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      _Dashboard(date: ref.watch(currentDateProvider));
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.date});

  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider).value ?? 'there';

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: RitualColors.accent,
        backgroundColor: RitualColors.surface,
        onRefresh: () async {
          ref.invalidate(dailyTriviaProvider);
          ref.invalidate(catQuestionProvider);
          ref.invalidate(seenActivitiesProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            RiseIn(
              duration: const Duration(milliseconds: 500),
              child: _Header(date: date, name: name),
            ),
            const RitualDivider(),
            const _ProgressSummary(),
            const RitualDivider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _WordleCard(),
                  SizedBox(height: RitualShape.stackGap),
                  _CatCard(),
                  SizedBox(height: RitualShape.stackGap),
                  _TriviaCard(),
                  SizedBox(height: RitualShape.stackGap),
                  _ExploreTeaser(),
                  SizedBox(height: RitualShape.stackGap),
                  _TodosCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date, required this.name});

  final String date;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(
                      DailyDateService.weekdayName(date),
                      letterSpacing: 0.14,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DailyDateService.monthDay(date),
                      style: outfit(
                        size: 15,
                        weight: FontWeight.w800,
                        color: RitualColors.accent,
                        letterSpacing: 0.02,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: RitualColors.borderStrong,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 17,
                  color: RitualColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Happy New Day, $name.', style: RitualText.greeting),
          const SizedBox(height: 6),
          Text('Your daily ritual is ready.', style: RitualText.bodySmall),
        ],
      ),
    );
  }
}

class _ProgressSummary extends ConsumerWidget {
  const _ProgressSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(dailyCompletionProvider);
    final cells = completion.availableStatuses;

    final streak = ref.watch(streaksProvider).overallCurrent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${completion.completed} / ${completion.total}',
                    style: RitualText.stat(26),
                  ),
                  const SizedBox(height: 2),
                  Eyebrow('Completed today', letterSpacing: 0.08),
                ],
              ),
              // The flame only appears once there is a streak to show — a
              // permanent "0 day streak" is just nagging.
              if (streak > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 18,
                        color: RitualColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text('$streak', style: RitualText.stat(20)),
                      const SizedBox(width: 6),
                      Eyebrow('day streak', letterSpacing: 0.06),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 5,
                    color: cells[i].completed
                        ? RitualColors.accent
                        : RitualColors.borderStrong,
                  ),
                ),
                if (i != cells.length - 1) const SizedBox(width: 3),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _WordleCard extends ConsumerWidget {
  const _WordleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(todayWordleProvider).value;
    final stats = ref.watch(wordleStatsProvider);
    final number = ref.watch(todayWordleNumberProvider);

    return RitualCard(
      onTap: () => context.push(Routes.wordle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Eyebrow('Wordle', color: RitualColors.accent),
              Text(
                '#$number',
                style: outfit(size: 11, color: RitualColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WordleBoard(
            rows: result?.grid?.split('\n') ?? const [],
            tileSize: 26,
            gap: 4,
          ),
          const SizedBox(height: 12),
          Text(
            result == null
                ? "Today's puzzle is waiting."
                : result.completed
                ? 'Solved in ${result.score}/6.'
                : "You didn't get this one.",
            style: RitualText.bodySmall,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: result == null ? 'Play Wordle' : 'View result',
            trailingArrow: true,
            onPressed: () => context.push(Routes.wordle),
          ),
          if (stats.total > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                StatBlock(value: '${stats.currentStreak}', label: 'Streak'),
                const SizedBox(width: 24),
                StatBlock(value: stats.averageLabel, label: 'Average'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CatCard extends ConsumerWidget {
  const _CatCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = ref.watch(catQuestionProvider);
    final result = ref.watch(catResultProvider).value;
    final accent = context.features.catQuant;

    return question.when(
      loading: () => LoadingCard(title: 'CAT Quant', accent: accent),
      error: (error, _) => ErrorCard(
        title: 'CAT Quant',
        error: error,
        accent: accent,
        onRetry: () => retryCatQuestion(ref),
      ),
      data: (data) {
        if (data == null) {
          return RitualCard(
            onTap: () => context.push(Routes.catQuant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('CAT Quant', color: accent),
                const SizedBox(height: 10),
                Text(
                  "Today's question isn't available yet.",
                  style: RitualText.bodySmall,
                ),
                const SizedBox(height: 10),
                InlineAction('Try again', color: accent),
              ],
            ),
          );
        }

        return RitualCard(
          onTap: () => context.push(Routes.catQuant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Eyebrow('CAT Quant', color: accent),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FeatureChip(
                      '${data.difficulty} · ${data.topic}',
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.stem,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: RitualText.bodySmall,
              ),
              const SizedBox(height: 10),
              if (result?.answered ?? false)
                Row(
                  children: [
                    Icon(
                      result!.correct ? Icons.check : Icons.close,
                      size: 15,
                      color: result.correct
                          ? RitualColors.success
                          : RitualColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result.correct ? 'Correct' : 'Incorrect',
                      style: outfit(
                        size: 12,
                        weight: FontWeight.w800,
                        color: result.correct
                            ? RitualColors.success
                            : RitualColors.error,
                        letterSpacing: 0.04,
                      ),
                    ),
                  ],
                )
              else
                InlineAction('Solve', color: accent),
            ],
          ),
        );
      },
    );
  }
}

class _TriviaCard extends ConsumerWidget {
  const _TriviaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trivia = ref.watch(dailyTriviaProvider);
    final result = ref.watch(triviaResultProvider).value;
    final accent = context.features.trivia;

    return trivia.when(
      loading: () => LoadingCard(title: 'Daily Trivia', accent: accent),
      error: (error, _) => ErrorCard(
        title: 'Daily Trivia',
        error: error,
        accent: accent,
        onRetry: () => ref.invalidate(dailyTriviaProvider),
      ),
      data: (question) => RitualCard(
        onTap: () => context.push(Routes.trivia),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Eyebrow('Daily Trivia', color: accent),
                const SizedBox(width: 8),
                Flexible(
                  child: FeatureChip(
                    '${question.category} · ${question.difficulty}',
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(question.question, style: RitualText.bodySmall),
            const SizedBox(height: 10),
            if (result?.answered ?? false)
              Row(
                children: [
                  Icon(
                    result!.correct ? Icons.check : Icons.close,
                    size: 15,
                    color: result.correct
                        ? RitualColors.success
                        : RitualColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    result.correct ? 'Correct' : 'Not quite',
                    style: outfit(
                      size: 12,
                      weight: FontWeight.w800,
                      color: result.correct
                          ? RitualColors.success
                          : RitualColors.error,
                      letterSpacing: 0.04,
                    ),
                  ),
                ],
              )
            else
              InlineAction('Answer', color: accent),
          ],
        ),
      ),
    );
  }
}

class _ExploreTeaser extends ConsumerWidget {
  const _ExploreTeaser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = context.features;

    return RitualCard(
      padding: RitualShape.cardPaddingCompact,
      onTap: () => StatefulNavigationShell.of(context).goBranch(1),
      child: Row(
        children: [
          for (final color in [features.pokemon, features.japan, features.fun])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 14,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More to explore today',
                  style: outfit(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pokémon · Animal · Fun',
                  style: outfit(size: 12, color: RitualColors.textTertiary),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            size: 16,
            color: RitualColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _TodosCard extends ConsumerWidget {
  const _TodosCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todayTodosProvider).take(3).toList();

    return RitualCard(
      padding: RitualShape.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Eyebrow('Todos', color: RitualColors.text, letterSpacing: 0.1),
              GestureDetector(
                onTap: () => StatefulNavigationShell.of(context).goBranch(2),
                child: Text(
                  'SEE ALL',
                  style: outfit(
                    size: 11,
                    weight: FontWeight.w800,
                    color: RitualColors.accent,
                    letterSpacing: 0.04,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (todos.isEmpty)
            Text('Nothing for today yet.', style: RitualText.bodySmall)
          else
            for (final todo in todos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: () => ref
                      .read(todoRepositoryProvider)
                      .setCompleted(todo.id, !todo.completed),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      RitualCheckbox(checked: todo.completed),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          todo.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: outfit(
                            size: 13,
                            color: todo.completed
                                ? RitualColors.textTertiary
                                : RitualColors.text,
                            decoration: todo.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
