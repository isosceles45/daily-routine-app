import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// Notifications, Appearance and Daily Content toggles arrive with the phases
/// that give them something to control. About is honest from day one.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: RiseIn(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Text('Settings', style: RitualText.tabTitle),
            const SizedBox(height: 14),
            const RitualDivider(),
            const SizedBox(height: 20),
            RitualCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('About'),
                  const SizedBox(height: 10),
                  Text('Daily Ritual v0.1.0', style: RitualText.bodySmall),
                  const SizedBox(height: 14),
                  Eyebrow('Live sources'),
                  const SizedBox(height: 8),
                  ..._sources.map(
                    (source) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '· $source',
                        style: outfit(
                            size: 12, color: RitualColors.textTertiary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _sources = [
    'OpenTDB — trivia, and the first CAT Quant tier',
    'PokéAPI — Pokémon of the day',
    'Cataas · Cat Facts — cats',
    'dog.ceo — dogs',
    'JokeAPI — jokes',
    'Useless Facts — weird facts',
    'math.js — verifies every generated CAT answer',
    'NYT Wordle — opened in your browser, never scraped',
  ];
}

