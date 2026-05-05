import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/di/injection.dart';
import 'package:swift_apply/app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final repo = getIt<OnboardingRepository>();
    final completed = await repo.isOnboardingCompleted();

    if (mounted) {
      if (completed) {
        context.go(AppRoute.home.path);
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/app_logo.png',
                width: 140,
                height: 140,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.rocket_launch_rounded,
                  size: 80,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Swift',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Apply',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
