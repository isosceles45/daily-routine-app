import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme.dart';

/// The app's own icon set.
///
/// Emoji were the placeholder: they render as someone else's artwork, in
/// someone else's colours, at a size and weight nothing else on screen shares —
/// and they change with the platform. These are line drawings authored to one
/// system (24px box, 1.7 stroke, round caps) that take the colour they are
/// given, so an icon sits at the same weight as the text beside it.
enum RitualIcons {
  // Animals
  cat,
  dog,
  fox,
  duck,
  bunny,

  // Fun
  joke,
  jokeDark('joke-dark'),
  fact,

  // Games
  bolt,
  grid,
  tiles,
  gamepad,
  flame,

  // Gym
  rest,
  chest,
  back,
  legs,
  shoulders,
  arms,
  abs,
  calves,
  cardio,

  // Countdowns
  calendar,
  plane,
  mountain,
  cake,
  note,
  graduation,
  party,
  ring,
  beach,
  train;

  const RitualIcons([this.file]);

  /// Set only where the asset name differs from the enum name.
  final String? file;

  String get asset => 'assets/icons/${file ?? name}.svg';

  static RitualIcons? byName(String? name) {
    if (name == null) return null;
    for (final icon in RitualIcons.values) {
      if (icon.name == name) return icon;
    }
    return null;
  }
}

/// Draws a [RitualIcons] at [size], tinted [color].
class RitualIcon extends StatelessWidget {
  const RitualIcon(this.icon, {super.key, this.size = 20, this.color});

  final RitualIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.asset,
      width: size,
      height: size,
      // The art is authored with `stroke="currentColor"`, so one filter tints
      // the whole drawing without needing a variant file per colour.
      colorFilter: ColorFilter.mode(
        color ?? RitualColors.text,
        BlendMode.srcIn,
      ),
    );
  }
}
