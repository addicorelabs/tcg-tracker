import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Navigation frame shared by the five top-level sections.
///
/// The app is used both on a phone and in a desktop browser, so the
/// destinations move to a side rail once there is room for one.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  static const double _railBreakpoint = 800;

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _destinations(l10n);
    final useRail = MediaQuery.sizeOf(context).width >= _railBreakpoint;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goToBranch,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _FloatingNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goToBranch,
        destinations: destinations,
      ),
    );
  }

  /// Tapping the destination you are already on pops that branch back to its
  /// root, which is the behaviour users expect from a tab bar.
  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<_Destination> _destinations(AppLocalizations l10n) => [
    _Destination(l10n.navHome, Icons.home_outlined, Icons.home),
    _Destination(
      l10n.navTournaments,
      Icons.emoji_events_outlined,
      Icons.emoji_events,
    ),
    _Destination(l10n.navAnalytics, Icons.insights_outlined, Icons.insights),
    _Destination(l10n.navDecks, Icons.style_outlined, Icons.style),
    _Destination(l10n.navSettings, Icons.settings_outlined, Icons.settings),
  ];
}

/// The bottom bar as a rounded pill inset from the edges of the screen.
///
/// It sits in the scaffold's bottom slot rather than over the body, so it takes
/// its own room and nothing scrolls underneath it. That costs the effect of
/// content sliding behind the bar, and buys not having to keep a bottom padding
/// in step across every scrolling screen in the app — get that wrong on one of
/// them and the last row of the list is unreachable.
class _FloatingNavigationBar extends StatelessWidget {
  const _FloatingNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_Destination> destinations;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(26));

    // `minimum` rather than plain padding: installed to the home screen, Flutter
    // Web reports no safe area at all, so relying on the inset alone would sit
    // the pill on top of the home indicator. Where the inset does arrive, it
    // wins.
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          // The bar has a fixed height and five fixed slots, so it cannot grow
          // with the system text size — past a point the labels are simply cut
          // off. The rest of the app still scales; only this strip is held back.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.1,
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
