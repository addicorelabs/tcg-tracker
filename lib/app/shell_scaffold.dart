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
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goToBranch,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
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

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
