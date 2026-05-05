import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoute.jobs.path)) return 1;
    if (location.startsWith(AppRoute.history.path)) return 2;
    if (location.startsWith(AppRoute.settings.path)) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoute.home,
      1 => AppRoute.jobs,
      2 => AppRoute.history,
      _ => AppRoute.settings,
    };
    context.go(route.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex(context),
          onTap: (index) => _onTap(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.send_rounded),
              label: 'Apply',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_history_rounded),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
