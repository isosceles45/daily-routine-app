import 'package:daily_ritual/app/theme.dart';
import 'package:daily_ritual/features/wordle/presentation/wordle_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(List<String> rows) => MaterialApp(
      theme: buildRitualTheme(),
      home: Scaffold(body: Center(child: WordleBoard(rows: rows))),
    );

/// Counts tiles painted in a given colour.
int tilesColoured(WidgetTester tester, Color color) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => (c.decoration as BoxDecoration?)?.color == color)
      .length;
}

void main() {
  testWidgets('an empty board still draws 6 x 5', (tester) async {
    await tester.pumpWidget(harness(const []));
    expect(find.byType(Container), findsNWidgets(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a solved grid paints greens and yellows', (tester) async {
    await tester.pumpWidget(harness(const [
      '⬛⬛🟨⬛⬛',
      '⬛🟨⬛⬛🟨',
      '🟨🟩⬛⬛⬛',
      '🟩🟩🟩🟩🟩',
    ]));
    await tester.pumpAndSettle();

    // 5 from the winning row plus the single green on row three.
    expect(tilesColoured(tester, RitualColors.success), 6);
    // Four yellows across the first three rows.
    expect(tilesColoured(tester, RitualColors.wordlePresent), 4);
  });

  testWidgets('pads a short board back out to six rows', (tester) async {
    await tester.pumpWidget(harness(const ['🟩🟩🟩🟩🟩']));
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsNWidgets(30));
    expect(tilesColoured(tester, RitualColors.success), 5);
  });

  testWidgets('renders the colour-blind palette too', (tester) async {
    // In high-contrast mode orange means correct and blue means present, so
    // both must map onto our own green and amber rather than being dropped.
    await tester.pumpWidget(harness(const ['🟧🟧🟧🟦🟦']));
    await tester.pumpAndSettle();

    expect(tilesColoured(tester, RitualColors.success), 3);
    expect(tilesColoured(tester, RitualColors.wordlePresent), 2);
  });

  testWidgets('a failed board fills all six rows', (tester) async {
    await tester.pumpWidget(harness(List.filled(6, '⬛⬛⬛⬛⬛')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Container), findsNWidgets(30));
  });
}
