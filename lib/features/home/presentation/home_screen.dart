import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/dates/daily_date_service.dart';
import '../../../core/providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../wordle/presentation/wordle_board.dart';
import '../../cat_quant/providers/cat_providers.dart';
import '../../challenges/providers/challenge_providers.dart';
import '../../surprise/providers/surprise_providers.dart';
import '../../games/domain/game_kind.dart';
import '../../games/providers/game_providers.dart';
import '../../todos/providers/todo_providers.dart';
import '../../trivia/providers/trivia_providers.dart';
import '../../wordle/providers/wordle_providers.dart';
import '../domain/daily_completion.dart';
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
    final name = ref.watch(preferencesProvider).value?.userName ?? 'there';

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                  _ChallengeRow(),
                  SizedBox(height: RitualShape.stackGap),
                  _TodosCard(),
                  SizedBox(height: RitualShape.stackGap),
                  _PlayCard(),
                ],
              ),
            ),
            // Full-bleed, and last: the day's list ends on the one thing that
            // isn't part of the day.
            const _SurpriseBand(),
          ],
        ),
      ),
    );
  }
}

/// The way out of the daily list.
///
/// Everything above it is finished once it is done; this is the row that is
/// still there afterwards, which is the whole reason the Play tab exists.
class _PlayCard extends ConsumerWidget {
  const _PlayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gameStatsProvider);
    final played = ref.watch(playedTodayProvider);

    return RitualCard(
      padding: RitualShape.cardPaddingCompact,
      onTap: () => context.push(Routes.play),
      child: Row(
        children: [
          const RitualIcon(
            RitualIcons.gamepad,
            size: 22,
            color: RitualColors.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(
                  played ? 'Played today' : 'Nothing daily about it',
                  color: RitualColors.accent,
                  size: 10,
                  letterSpacing: 0.08,
                ),
                const SizedBox(height: 3),
                Text('Play', style: RitualText.stat(17)),
                const SizedBox(height: 2),
                Text(
                  [
                    for (final game in GameKind.values)
                      stats[game]?.best == null
                          ? game.label
                          : '${game.label} ${stats[game]!.best}',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: outfit(size: 11.5, color: RitualColors.textTertiary),
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
          const SizedBox(height: 14),
          _Remaining(completion: completion),
        ],
      ),
    );
  }
}

/// The canvas draws this as a bordered row rather than a card — it is a nudge,
/// not a section.
class _ChallengeRow extends ConsumerWidget {
  const _ChallengeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(dailyChallengeProvider);
    final done = ref.watch(challengeDoneProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: Border.all(color: RitualColors.borderStrong, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.adjust_rounded,
            size: 17,
            color: RitualColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.text, style: RitualText.bodySmall),
                if (challenge.origin != null) ...[
                  const SizedBox(height: 3),
                  Eyebrow(challenge.origin!, size: 10, letterSpacing: 0.08),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: done ? RitualColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(RitualShape.inputRadius),
            child: InkWell(
              onTap: () => toggleChallenge(ref),
              borderRadius: BorderRadius.circular(RitualShape.inputRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: done
                      ? null
                      : Border.all(
                          color: RitualColors.borderStrong,
                          width: 1.5,
                        ),
                  borderRadius: BorderRadius.circular(RitualShape.inputRadius),
                ),
                child: Text(
                  done ? 'DONE' : 'DONE?',
                  style: outfit(
                    size: 11,
                    weight: FontWeight.w800,
                    color: done
                        ? RitualColors.onAccent
                        : RitualColors.textSecondary,
                    letterSpacing: 0.04,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The closing band of the Today page.
///
/// Every other section is a rounded card inside the page padding; this one
/// breaks the margin deliberately. Surprise Me is the one thing on Today that
/// is *not* part of the day, and letting it run edge to edge is what says so.
class _SurpriseBand extends ConsumerWidget {
  const _SurpriseBand();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolled = ref.watch(surpriseCountProvider).value ?? 0;

    return Material(
      color: RitualColors.accent,
      child: InkWell(
        onTap: () => context.push(Routes.surpriseRoll),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: RitualColors.onAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rolled == 0 ? 'SURPRISE ME' : 'ROLLED $rolled TODAY',
                          style: outfit(
                            size: 10,
                            weight: FontWeight.w800,
                            color: RitualColors.onAccent,
                            letterSpacing: 0.14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rolled == 0
                          ? 'Give me something\nunexpected.'
                          : 'Pull another one.',
                      style: outfit(
                        size: 24,
                        weight: FontWeight.w800,
                        color: RitualColors.onAccent,
                        letterSpacing: -0.015,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // A single large target rather than a small pill — the band is
              // the button, this just says which way it goes.
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: RitualColors.onAccent, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: RitualColors.onAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Names what is still outstanding.
///
/// The bar row shows proportion; this says which. Without it the user can see
/// that one of seven is missing but has to scan the whole page to find it.
class _Remaining extends StatelessWidget {
  const _Remaining({required this.completion});

  final DailyCompletion completion;

  @override
  Widget build(BuildContext context) {
    if (completion.total == 0) return const SizedBox.shrink();

    if (completion.isComplete) {
      return Row(
        children: [
          const Icon(
            Icons.check_rounded,
            size: 15,
            color: RitualColors.success,
          ),
          const SizedBox(width: 6),
          Text(
            "That's everything today.",
            style: outfit(
              size: 12,
              weight: FontWeight.w700,
              color: RitualColors.success,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Still to do', size: 10, letterSpacing: 0.1),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final activity in completion.remaining)
              FeatureChip(activity.label),
          ],
        ),
      ],
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

    // The card and its button do the same thing, so tapping anywhere on the
    // card behaves the way the button label promises.
    final route = wordleRouteFor(result);

    return RitualCard(
      onTap: () => context.push(route),
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
            onPressed: () => context.push(route),
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
          for (final color in [features.pokemon, features.place, features.fun])
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
