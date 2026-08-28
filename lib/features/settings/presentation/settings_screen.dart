import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).value;

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

            Eyebrow('You'),
            const SizedBox(height: 10),
            _NameField(
              value: prefs?.userName ?? '',
              onSubmit: (name) =>
                  ref.read(preferencesProvider.notifier).setUserName(name),
            ),
            const SizedBox(height: 24),

            Eyebrow('Daily content'),
            const SizedBox(height: 6),
            _Toggle(
              label: 'Dark jokes on Saturdays',
              description: 'Off swaps them for an ordinary joke.',
              value: prefs?.allowDarkJokes ?? true,
              onChanged: (v) =>
                  ref.read(preferencesProvider.notifier).setAllowDarkJokes(v),
            ),
            const SizedBox(height: 24),

            Eyebrow('Notifications'),
            const SizedBox(height: 6),
            _Toggle(
              label: 'Daily reminders',
              description:
                  "Saved now; we'll ask for permission when they arrive.",
              value: prefs?.dailyReminders ?? false,
              onChanged: (v) =>
                  ref.read(preferencesProvider.notifier).setDailyReminders(v),
            ),
            const SizedBox(height: 24),

            Eyebrow('About'),
            const SizedBox(height: 10),
            RitualCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ritual v0.1.0', style: RitualText.bodySmall),
                  const SizedBox(height: 14),
                  Eyebrow('Live sources', size: 10, letterSpacing: 0.08),
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
    'Wikipedia — Japan of the day',
    'Cataas · Cat Facts — cats',
    'dog.ceo — dogs',
    'JokeAPI — jokes',
    'Useless Facts — weird facts',
    'math.js — verifies every generated CAT answer',
    'NYT Wordle — opened in your browser, never scraped',
  ];
}

class _NameField extends StatefulWidget {
  const _NameField({required this.value, required this.onSubmit});

  final String value;
  final ValueChanged<String> onSubmit;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The preference loads asynchronously, so adopt it once — but never
    // overwrite what the user is currently typing.
    if (oldWidget.value.isEmpty && widget.value.isNotEmpty && !_dirty) {
      _controller.text = widget.value;
    }
  }

  bool _dirty = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(RitualShape.inputRadius),
          borderSide: BorderSide(color: c, width: 1.5),
        );

    return TextField(
      controller: _controller,
      style: outfit(size: 14),
      textInputAction: TextInputAction.done,
      onChanged: (_) => _dirty = true,
      onSubmitted: widget.onSubmit,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
        if (_dirty) widget.onSubmit(_controller.text);
      },
      decoration: InputDecoration(
        labelText: 'Name in the greeting',
        labelStyle: outfit(size: 12, color: RitualColors.textTertiary),
        filled: true,
        fillColor: RitualColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: border(RitualColors.borderStrong),
        enabledBorder: border(RitualColors.borderStrong),
        focusedBorder: border(RitualColors.accent),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: RitualColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: outfit(size: 14)),
                  const SizedBox(height: 2),
                  Text(description,
                      style: outfit(
                          size: 12, color: RitualColors.textTertiary)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: RitualColors.onAccent,
              activeTrackColor: RitualColors.accent,
              inactiveThumbColor: RitualColors.textTertiary,
              inactiveTrackColor: RitualColors.surfaceRaised,
            ),
          ],
        ),
      ),
    );
  }
}
