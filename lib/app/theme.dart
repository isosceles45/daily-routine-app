import 'package:flutter/material.dart';

/// Colour tokens lifted verbatim from `design/Daily Ritual.dc.html`.
///
/// The canvas is the UI source of truth; nothing here should be invented.
abstract final class RitualColors {
  static const bg = Color(0xFF14131A);
  static const surface = Color(0xFF1E1D26);
  static const surfaceRaised = Color(0xFF292733);
  static const border = Color(0xFF2D2B37);
  static const borderStrong = Color(0xFF3A3846);

  static const text = Color(0xFFF5F3F7);
  static const textSecondary = Color(0xFFADA9B8);
  static const textTertiary = Color(0xFF7C7889);

  static const accent = Color(0xFFFF5CA8);
  static const accentSoft = Color(0xFF3D1C2C);
  static const accentSoftText = Color(0xFFFFB4D3);
  static const onAccent = Color(0xFF26101B);

  /// Wordle's "right letter, wrong place" tile.
  ///
  /// The canvas drew this as a dark tile with an accent border, but everyone
  /// already knows what a yellow Wordle tile means — reusing the palette's
  /// amber reads instantly and costs nothing.
  static const wordlePresent = Color(0xFFFFC24D);

  static const success = Color(0xFF2FD1A0);
  static const successOn = Color(0xFF06231A);
  static const error = Color(0xFFFF6B6B);
}

/// Per-feature accents. Each daily section owns one colour.
@immutable
class FeatureColors extends ThemeExtension<FeatureColors> {
  const FeatureColors({
    required this.catQuant,
    required this.trivia,
    required this.pokemon,
    required this.japan,
    required this.fun,
  });

  final Color catQuant;
  final Color trivia;
  final Color pokemon;
  final Color japan;
  final Color fun;

  static const dark = FeatureColors(
    catQuant: Color(0xFF7C8BFF),
    trivia: Color(0xFFFFC24D),
    pokemon: Color(0xFFBD8DFF),
    japan: Color(0xFFFF7A68),
    fun: Color(0xFF2FD1A0),
  );

  @override
  FeatureColors copyWith({
    Color? catQuant,
    Color? trivia,
    Color? pokemon,
    Color? japan,
    Color? fun,
  }) {
    return FeatureColors(
      catQuant: catQuant ?? this.catQuant,
      trivia: trivia ?? this.trivia,
      pokemon: pokemon ?? this.pokemon,
      japan: japan ?? this.japan,
      fun: fun ?? this.fun,
    );
  }

  @override
  FeatureColors lerp(covariant FeatureColors? other, double t) {
    if (other == null) return this;
    return FeatureColors(
      catQuant: Color.lerp(catQuant, other.catQuant, t)!,
      trivia: Color.lerp(trivia, other.trivia, t)!,
      pokemon: Color.lerp(pokemon, other.pokemon, t)!,
      japan: Color.lerp(japan, other.japan, t)!,
      fun: Color.lerp(fun, other.fun, t)!,
    );
  }
}

extension FeatureColorsX on BuildContext {
  FeatureColors get features =>
      Theme.of(this).extension<FeatureColors>() ?? FeatureColors.dark;
}

/// Outfit is bundled as a single variable font, so weight must be applied
/// through [FontVariation] as well as [FontWeight] — `fontWeight` alone would
/// leave the renderer on the default instance and synthesise a fake bold.
TextStyle outfit({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = RitualColors.text,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  FontFeature? feature,
}) {
  return TextStyle(
    fontFamily: 'Outfit',
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
    letterSpacing: letterSpacing == null ? null : size * letterSpacing,
    height: height,
    decoration: decoration,
    decorationColor: color,
    fontFeatures: feature == null ? null : [feature],
  );
}

/// The canvas type scale. `letterSpacing` values are em-relative, matching CSS.
abstract final class RitualText {
  static TextStyle get greeting => outfit(
    size: 30,
    weight: FontWeight.w800,
    letterSpacing: -0.015,
    height: 1.08,
  );

  static TextStyle get tabTitle => outfit(size: 22, weight: FontWeight.w800);

  static TextStyle get screenTitle =>
      outfit(size: 15, weight: FontWeight.w800, letterSpacing: 0.02);

  static TextStyle get questionStem =>
      outfit(size: 19, weight: FontWeight.w800, height: 1.4);

  static TextStyle get questionStemSmall =>
      outfit(size: 17, weight: FontWeight.w600, height: 1.5);

  /// Big numerals use tabular figures so stats don't jitter as they change.
  static TextStyle stat(double size) => outfit(
    size: size,
    weight: FontWeight.w800,
    feature: const FontFeature.tabularFigures(),
  );

  static TextStyle get body =>
      outfit(size: 14, color: RitualColors.textSecondary, height: 1.5);

  static TextStyle get bodySmall =>
      outfit(size: 13, color: RitualColors.textSecondary, height: 1.4);

  /// The small uppercase section labels used throughout the canvas.
  static TextStyle eyebrow({
    double size = 11,
    Color color = RitualColors.textTertiary,
    double letterSpacing = 0.12,
  }) => outfit(
    size: size,
    weight: FontWeight.w800,
    color: color,
    letterSpacing: letterSpacing,
  );
}

/// Geometry constants from the canvas.
abstract final class RitualShape {
  static const cardRadius = 16.0;
  static const accentCardRadius = 20.0;
  static const buttonRadius = 10.0;
  static const optionRadius = 10.0;
  static const inputRadius = 8.0;
  static const chipRadius = 6.0;
  static const checkboxRadius = 5.0;

  static const cardPadding = EdgeInsets.all(18);
  static const cardPaddingCompact = EdgeInsets.all(16);
  static const screenPadding = EdgeInsets.all(20);

  /// Vertical gap between stacked cards.
  static const stackGap = 14.0;

  static const cardShadow = [
    BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Above this width the canvas switches to its two-column layout.
  static const tabletBreakpoint = 900.0;
}

ThemeData buildRitualTheme() {
  const scheme = ColorScheme.dark(
    primary: RitualColors.accent,
    onPrimary: RitualColors.onAccent,
    secondary: RitualColors.accentSoftText,
    onSecondary: RitualColors.onAccent,
    surface: RitualColors.surface,
    onSurface: RitualColors.text,
    error: RitualColors.error,
    onError: RitualColors.text,
    outline: RitualColors.borderStrong,
    outlineVariant: RitualColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: RitualColors.bg,
    canvasColor: RitualColors.bg,
    fontFamily: 'Outfit',
    splashFactory: InkSparkle.splashFactory,
    extensions: const [FeatureColors.dark],
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: RitualColors.accent,
      selectionColor: Color(0x59FF5CA8),
      selectionHandleColor: RitualColors.accent,
    ),
    dividerTheme: const DividerThemeData(
      color: RitualColors.border,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: RitualColors.surfaceRaised,
      contentTextStyle: outfit(size: 13),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
