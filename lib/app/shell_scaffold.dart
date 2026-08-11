import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../shared/layout/bar_insets.dart';

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
      // The bar floats over the body instead of sitting beside it, so the app
      // carries on behind and around the pill. The price is that no screen gets
      // its bottom clearance for free: see [FloatingBar].
      extendBody: true,
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
/// Its size and margins come from [FloatingBar], which is also where every
/// screen reads the room it has to leave at the bottom: the two numbers are the
/// same number, and they stop agreeing the moment they are written twice.
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

    // Fixed margins rather than a SafeArea: installed to the home screen,
    // Flutter Web reports no safe area at all, and every screen has to leave
    // room for this bar from a constant anyway — see `FloatingBar`. The side
    // margins are as wide as the labels allow, since every pixel taken off
    // here comes off a fifth of the pill and "Impostazioni" has to fit in one
    // of those fifths.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FloatingBar.sideMargin,
        0,
        FloatingBar.sideMargin,
        FloatingBar.bottomMargin,
      ),
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
