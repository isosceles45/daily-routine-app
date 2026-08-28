import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';

/// The five-tab frame from the canvas: page body above, a bottom bar with a
/// 2px top rule and a 2px accent indicator over the active item.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    (icon: Icons.home_outlined, label: 'Today'),
    (icon: Icons.explore_outlined, label: 'Explore'),
    (icon: Icons.checklist_rounded, label: 'Todos'),
    (icon: Icons.schedule_rounded, label: 'History'),
    (icon: Icons.tune_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RitualColors.bg,
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: RitualColors.bg,
          border: Border(
            top: BorderSide(color: RitualColors.borderStrong, width: 2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: _NavItem(
                      icon: _items[i].icon,
                      label: _items[i].label,
                      active: shell.currentIndex == i,
                      // `initialLocation: true` when re-tapping the current tab
                      // pops it back to its root, which is what a second tap on
                      // an already-selected tab should do.
                      onTap: () => shell.goBranch(
                        i,
                        initialLocation: i == shell.currentIndex,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? RitualColors.accent : RitualColors.textTertiary;

    return Semantics(
      selected: active,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        // A Stack sizes to its largest non-positioned child and aligns it
        // topStart by default, which pinned every icon and label to the left
        // of its slot while the indicator stayed centred. Centring the stack
        // and stretching the column keeps the two in agreement.
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Container(
                    height: 2,
                    color: active ? RitualColors.accent : Colors.transparent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 21, color: color),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    style: outfit(
                      size: 10,
                      weight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.03,
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
}

/// Header for the full-screen detail routes: back chevron, title, 2px rule.
class DetailScaffold extends StatelessWidget {
  const DetailScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RitualColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: RitualColors.borderStrong,
                    width: 2,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.chevron_left, size: 24),
                      color: RitualColors.text,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: RitualText.screenTitle),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: RitualShape.screenPadding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
