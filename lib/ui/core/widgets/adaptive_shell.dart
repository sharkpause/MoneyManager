import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/layout_breakpoints.dart';

/// Adaptive navigation shell switching between [NavigationBar] (< 600px)
/// and [NavigationRail] (>= 600px) based on available window width.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = <({String label, IconData icon, IconData selectedIcon})>[
    (
      label: 'Overview',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    (
      label: 'Ledger',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    (
      label: 'Reports',
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= LayoutBreakpoints.expandedWidth;

        if (isExpanded) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final dest in _destinations)
                      NavigationRailDestination(
                        icon: Icon(dest.icon),
                        selectedIcon: Icon(dest.selectedIcon),
                        label: Text(dest.label),
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
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              for (final dest in _destinations)
                NavigationDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: dest.label,
                ),
            ],
          ),
        );
      },
    );
  }
}
