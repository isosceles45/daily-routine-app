import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/game_kind.dart';
import '../domain/sudoku.dart';
import '../providers/game_providers.dart';

class SudokuScreen extends ConsumerStatefulWidget {
  const SudokuScreen({super.key});

  @override
  ConsumerState<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends ConsumerState<SudokuScreen> {
  SudokuPuzzle? _puzzle;
  List<int> _grid = List.filled(Sudoku.cells, 0);
  List<Set<int>> _notes = [for (var i = 0; i < Sudoku.cells; i++) <int>{}];

  int? _selected;
  bool _noteMode = false;
  bool _generating = false;
  bool _solved = false;

  /// Wrong entries the user has made, counted for the score.
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreOrOffer());
  }

  Future<void> _restoreOrOffer() async {
    final saved = await ref
        .read(gameRepositoryProvider)
        .readState(GameKind.sudoku);
    if (!mounted || saved == null) return;

    try {
      setState(() {
        _puzzle = SudokuPuzzle.fromJson(
          saved['puzzle'] as Map<String, dynamic>,
        );
        _grid = (saved['grid'] as List<dynamic>).cast<int>();
        _notes = [
          for (final n in saved['notes'] as List<dynamic>)
            (n as List<dynamic>).cast<int>().toSet(),
        ];
        _mistakes = saved['mistakes'] as int? ?? 0;
      });
    } on Object {
      // A save we cannot read is not worth blocking a new game over.
      await ref.read(gameRepositoryProvider).clearState(GameKind.sudoku);
    }
  }

  Future<void> _save() async {
    final puzzle = _puzzle;
    if (puzzle == null || _solved) return;

    await ref.read(gameRepositoryProvider).saveState(GameKind.sudoku, {
      'puzzle': puzzle.toJson(),
      'grid': _grid,
      'notes': [for (final n in _notes) n.toList()],
      'mistakes': _mistakes,
    });
  }

  Future<void> _newGame(SudokuDifficulty difficulty) async {
    setState(() => _generating = true);

    // Generation is fast, but not free — yielding first lets the spinner paint.
    await Future<void>.delayed(const Duration(milliseconds: 16));
    final puzzle = Sudoku.generate(difficulty);

    if (!mounted) return;
    setState(() {
      _puzzle = puzzle;
      _grid = [...puzzle.givens];
      _notes = [for (var i = 0; i < Sudoku.cells; i++) <int>{}];
      _selected = null;
      _solved = false;
      _mistakes = 0;
      _generating = false;
    });
    await _save();
  }

  void _enter(int value) {
    final puzzle = _puzzle;
    final index = _selected;
    if (puzzle == null || index == null || puzzle.isGiven(index)) return;

    setState(() {
      if (_noteMode && value != 0) {
        if (!_notes[index].remove(value)) _notes[index].add(value);
        return;
      }

      _notes[index].clear();
      _grid[index] = _grid[index] == value ? 0 : value;

      if (_grid[index] != 0 && _grid[index] != puzzle.solution[index]) {
        _mistakes++;
      }
    });

    if (Sudoku.isComplete(_grid)) {
      _finish();
    } else {
      _save();
    }
  }

  Future<void> _finish() async {
    final puzzle = _puzzle;
    if (puzzle == null) return;

    setState(() => _solved = true);

    // A clean grid is worth full marks; every wrong entry costs.
    final score = (puzzle.difficulty.scoreBase - _mistakes * 25).clamp(
      50,
      100000,
    );

    final repo = ref.read(gameRepositoryProvider);
    await repo.recordScore(
      game: GameKind.sudoku,
      score: score,
      date: ref.read(currentDateProvider),
      detail: {'difficulty': puzzle.difficulty.name, 'mistakes': _mistakes},
    );
    await repo.clearState(GameKind.sudoku);
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;

    // A Column, not a ListView: DetailScaffold already wraps its child in a
    // scroll view, and a ListView inside one has no bounded height.
    return DetailScaffold(
      title: 'Sudoku',
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_generating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: RitualColors.accent),
              ),
            )
          else if (puzzle == null)
            _DifficultyPicker(onPick: _newGame)
          else ...[
            _Status(
              difficulty: puzzle.difficulty,
              mistakes: _mistakes,
              solved: _solved,
            ),
            const SizedBox(height: 12),
            _Board(
              grid: _grid,
              notes: _notes,
              puzzle: puzzle,
              selected: _selected,
              conflicts: Sudoku.conflicts(_grid),
              onTap: (i) => setState(() => _selected = i),
            ),
            const SizedBox(height: 16),
            if (_solved)
              _SolvedPanel(onNew: () => setState(() => _puzzle = null))
            else ...[
              _Keypad(
                onDigit: _enter,
                noteMode: _noteMode,
                onToggleNotes: () => setState(() => _noteMode = !_noteMode),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _puzzle = null),
                child: Text(
                  'New puzzle',
                  style: outfit(size: 13, color: RitualColors.textTertiary),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DifficultyPicker extends ConsumerWidget {
  const _DifficultyPicker({required this.onPick});

  final void Function(SudokuDifficulty) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final best = ref.watch(gameStatsProvider)[GameKind.sudoku]?.best;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const RitualIcon(
          RitualIcons.grid,
          size: 42,
          color: RitualColors.accent,
        ),
        const SizedBox(height: 12),
        Text('Pick a difficulty', style: RitualText.stat(24)),
        const SizedBox(height: 6),
        Text(
          'Every puzzle is generated fresh and has exactly one solution.',
          style: RitualText.bodySmall,
        ),
        if (best != null) ...[
          const SizedBox(height: 10),
          Text(
            'Best $best pts',
            style: outfit(
              size: 13,
              weight: FontWeight.w800,
              color: RitualColors.accent,
            ),
          ),
        ],
        const SizedBox(height: 22),
        for (final difficulty in SudokuDifficulty.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RitualCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () => onPick(difficulty),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      difficulty.label,
                      style: outfit(size: 15, weight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${difficulty.givens} clues',
                    style: outfit(size: 12, color: RitualColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.difficulty,
    required this.mistakes,
    required this.solved,
  });

  final SudokuDifficulty difficulty;
  final int mistakes;
  final bool solved;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Eyebrow(
          difficulty.label,
          color: RitualColors.accent,
          letterSpacing: 0.12,
        ),
        const Spacer(),
        if (solved)
          Text(
            'Solved',
            style: outfit(
              size: 13,
              weight: FontWeight.w800,
              color: RitualColors.success,
            ),
          )
        else if (mistakes > 0)
          Text(
            '$mistakes mistake${mistakes == 1 ? '' : 's'}',
            style: outfit(size: 12, color: RitualColors.error),
          ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.grid,
    required this.notes,
    required this.puzzle,
    required this.selected,
    required this.conflicts,
    required this.onTap,
  });

  final List<int> grid;
  final List<Set<int>> notes;
  final SudokuPuzzle puzzle;
  final int? selected;
  final Set<int> conflicts;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final selectedValue = selected == null || grid[selected!] == 0
        ? null
        : grid[selected!];

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: RitualColors.borderStrong, width: 1.5),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: Sudoku.cells,
          itemBuilder: (context, i) => _Cell(
            index: i,
            value: grid[i],
            notes: notes[i],
            given: puzzle.isGiven(i),
            selected: selected == i,
            // Highlighting the row, column and box is the single biggest
            // readability win on a phone-sized grid.
            related: selected != null && _isRelated(selected!, i),
            sameValue:
                selectedValue != null &&
                grid[i] == selectedValue &&
                selected != i,
            conflicted: conflicts.contains(i),
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }

  static bool _isRelated(int a, int b) =>
      Sudoku.row(a) == Sudoku.row(b) ||
      Sudoku.col(a) == Sudoku.col(b) ||
      Sudoku.box(a) == Sudoku.box(b);
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.index,
    required this.value,
    required this.notes,
    required this.given,
    required this.selected,
    required this.related,
    required this.sameValue,
    required this.conflicted,
    required this.onTap,
  });

  final int index;
  final int value;
  final Set<int> notes;
  final bool given;
  final bool selected;
  final bool related;
  final bool sameValue;
  final bool conflicted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final row = Sudoku.row(index);
    final col = Sudoku.col(index);

    final background = conflicted
        ? RitualColors.error.withValues(alpha: 0.22)
        : selected
        ? RitualColors.accent.withValues(alpha: 0.28)
        : sameValue
        ? RitualColors.accent.withValues(alpha: 0.12)
        : related
        ? RitualColors.surfaceRaised
        : RitualColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: Border(
            // The heavy lines are what make a 9×9 read as nine boxes.
            right: BorderSide(
              color: col % 3 == 2
                  ? RitualColors.borderStrong
                  : RitualColors.border,
              width: col % 3 == 2 ? 1.4 : 0.5,
            ),
            bottom: BorderSide(
              color: row % 3 == 2
                  ? RitualColors.borderStrong
                  : RitualColors.border,
              width: row % 3 == 2 ? 1.4 : 0.5,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: value != 0
            ? Text(
                '$value',
                style: outfit(
                  size: 17,
                  weight: given ? FontWeight.w800 : FontWeight.w600,
                  color: conflicted
                      ? RitualColors.error
                      : given
                      ? RitualColors.text
                      : RitualColors.accent,
                ),
              )
            : notes.isEmpty
            ? null
            : _Notes(notes: notes),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes({required this.notes});

  final Set<int> notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, i) => Center(
          child: Text(
            notes.contains(i + 1) ? '${i + 1}' : '',
            style: outfit(size: 7.5, color: RitualColors.textTertiary),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.noteMode,
    required this.onToggleNotes,
  });

  final void Function(int) onDigit;
  final bool noteMode;
  final VoidCallback onToggleNotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var d = 1; d <= 9; d++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _Key(label: '$d', onTap: () => onDigit(d)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Key(label: 'Erase', onTap: () => onDigit(0)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Key(
                label: noteMode ? 'Notes on' : 'Notes off',
                active: noteMode,
                onTap: onToggleNotes,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, this.active = false});

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? RitualColors.accent.withValues(alpha: 0.2)
          : RitualColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? RitualColors.accent : RitualColors.border,
            ),
          ),
          child: Text(
            label,
            style: outfit(
              size: 14,
              weight: FontWeight.w700,
              color: active ? RitualColors.accent : RitualColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _SolvedPanel extends StatelessWidget {
  const _SolvedPanel({required this.onNew});

  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Solved', style: RitualText.stat(26)),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Another', onPressed: onNew),
      ],
    );
  }
}
