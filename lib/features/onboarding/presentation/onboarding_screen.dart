import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../settings/providers/settings_providers.dart';

/// First launch.
///
/// There is no account and no sign-in: the app has nothing to protect and
/// nothing on a server (§13). This asks for a name so the greeting is yours,
/// and for the two preferences that shape what the app shows you — then gets
/// out of the way.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  bool _darkJokes = true;
  bool _reminders = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);

    await ref
        .read(preferencesProvider.notifier)
        .completeOnboarding(
          name: _name.text,
          allowDarkJokes: _darkJokes,
          dailyReminders: _reminders,
        );

    // Skip the Happy New Day greeting today — the user has just been welcomed;
    // greeting them again immediately would be two hellos in a row.
    final date = ref.read(currentDateProvider);
    final db = ref.read(databaseProvider);
    await db.ensureDay(date);
    await db.markGreetingShown(date);
    ref.invalidate(dailyStateProvider);

    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RitualColors.bg,
      child: SafeArea(
        child: Padding(
          // Lift the screen above the keyboard rather than letting it cover
          // the field being typed into.
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              // The content scrolls and the button does not, which keeps Start
              // reachable on any screen height.
              //
              // This deliberately avoids Spacer: a scroll view hands its child
              // unbounded height, and Spacer is a Flexible that needs a bounded
              // main axis to divide up. Inside a SingleChildScrollView it can
              // never lay out.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Sunrise(),
                      const SizedBox(height: 26),
                      Text('Ritual', style: RitualText.greeting),
                      const SizedBox(height: 8),
                      Text(
                        'Something to do, learn, laugh at and be surprised by '
                        '— every day.',
                        style: outfit(
                          size: 15,
                          color: RitualColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      Eyebrow('What should I call you?'),
                      const SizedBox(height: 10),
                      _NameField(controller: _name, onSubmit: (_) => _finish()),

                      const SizedBox(height: 30),
                      Eyebrow('Your daily content'),
                      const SizedBox(height: 6),
                      _Toggle(
                        label: 'Dark jokes on Saturdays',
                        description: 'Off swaps them for an ordinary one.',
                        value: _darkJokes,
                        onChanged: (v) => setState(() => _darkJokes = v),
                      ),
                      _Toggle(
                        label: 'Daily reminders',
                        // Saying so up front beats a switch that quietly does
                        // nothing for a release or two.
                        description:
                            "We'll ask for permission when reminders arrive.",
                        value: _reminders,
                        onChanged: (v) => setState(() => _reminders = v),
                      ),

                      const SizedBox(height: 26),
                      Text(
                        'No account, nothing uploaded. Everything stays on '
                        'this device, and all of it is changeable in Settings.',
                        style: outfit(
                          size: 12,
                          color: RitualColors.textTertiary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                child: PrimaryButton(
                  label: _saving ? 'Setting up…' : 'Start',
                  trailingArrow: true,
                  onPressed: _saving ? null : _finish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app mark, drawn rather than loaded, so onboarding needs no assets.
class _Sunrise extends StatelessWidget {
  const _Sunrise();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(painter: _SunrisePainter()),
    );
  }
}

class _SunrisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;
    final r = size.width * 0.26;

    final sun = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [RitualColors.accent, Color(0xFFBD8DFF)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.14159,
      3.14159,
      true,
      sun,
    );

    final horizon = Paint()
      ..color = RitualColors.accent
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - r * 1.55, cy),
      Offset(cx + r * 1.55, cy),
      horizon,
    );

    final ray = Paint()
      ..color = const Color(0xFFBD8DFF)
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final a = (200 + i * 35) * 3.14159 / 180;
      canvas.drawLine(
        Offset(cx + r * 1.4 * _cos(a), cy + r * 1.4 * _sin(a)),
        Offset(cx + r * 1.78 * _cos(a), cy + r * 1.78 * _sin(a)),
        ray,
      );
    }
  }

  static double _cos(double a) => math.cos(a);
  static double _sin(double a) => math.sin(a);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(RitualShape.inputRadius),
      borderSide: BorderSide(color: c, width: 1.5),
    );

    return TextField(
      controller: controller,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmit,
      style: outfit(size: 16),
      decoration: InputDecoration(
        hintText: 'Your name',
        hintStyle: outfit(size: 16, color: RitualColors.textTertiary),
        filled: true,
        fillColor: RitualColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
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
                  Text(
                    description,
                    style: outfit(size: 12, color: RitualColors.textTertiary),
                  ),
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
