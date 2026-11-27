import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/core/theme/app_theme.dart';
import 'ui/core/widgets/adaptive_shell.dart';
import 'ui/features/overview/overview_screen.dart';

/// Root Money Manager application configured with adaptive routing and theming.
class MoneyManagerApp extends StatelessWidget {
  MoneyManagerApp({super.key});

  late final GoRouter _router = GoRouter(
    initialLocation: '/overview',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/overview',
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ledger',
                builder: (context, state) => const _PlaceholderSection(title: 'Ledger'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const _PlaceholderSection(title: 'Reports'),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Money Manager',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title coming soon')),
    );
  }
}
