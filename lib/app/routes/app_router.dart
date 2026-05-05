import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/core/presentation/shell/app_shell.dart';
import 'package:swift_apply/app/features/cv/presentation/screens/cv_library_screen.dart';
import 'package:swift_apply/app/features/history/presentation/screens/history_screen.dart';
import 'package:swift_apply/app/features/home/presentation/screens/home_screen.dart';
import 'package:swift_apply/app/features/job_leads/presentation/screens/job_leads_screen.dart';
import 'package:swift_apply/app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:swift_apply/app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:swift_apply/app/features/settings/presentation/screens/settings_screen.dart';

enum AppRoute {
  splash('/splash'),
  onboarding('/onboarding'),
  home('/'),
  jobs('/jobs'),
  settings('/settings'),
  history('/history'),
  cvLibrary('/settings/cv-library');

  const AppRoute(this.path);
  final String path;
}

@lazySingleton
class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: AppRoute.splash.path,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            name: AppRoute.home.name,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoute.history.path,
            name: AppRoute.history.name,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoute.jobs.path,
            name: AppRoute.jobs.name,
            builder: (context, state) => const JobLeadsScreen(),
          ),
          GoRoute(
            path: AppRoute.settings.path,
            name: AppRoute.settings.name,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.cvLibrary.path,
        name: AppRoute.cvLibrary.name,
        builder: (context, state) => const CvLibraryScreen(),
      ),
    ],
  );
}
