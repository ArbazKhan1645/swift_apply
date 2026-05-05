import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/di/injection.dart';
import 'package:swift_apply/app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    const _OnboardingData(
      title: 'Smart Job Application',
      subtitle:
          'Paste any job post and let SwiftApply extract details and auto-fill your application in seconds.',
      icon: Icons.auto_awesome_rounded,
      color: AppTheme.accent,
    ),
    const _OnboardingData(
      title: 'Dual Outreach Mode',
      subtitle:
          'Send applications directly via SMTP Email or WhatsApp Business API. Smooth, fast, and professional.',
      icon: Icons.rocket_launch_rounded,
      color: AppTheme.accentAlt,
    ),
  ];

  Future<void> _complete() async {
    await getIt<OnboardingRepository>().completeOnboarding();
    if (mounted) {
      context.go(AppRoute.home.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, idx) {
                  final data = _pages[idx];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: data.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(data.icon, size: 80, color: data.color),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == idx ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx
                              ? AppTheme.accent
                              : AppTheme.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AccentButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    icon: _currentPage == _pages.length - 1
                        ? Icons.check_rounded
                        : Icons.chevron_right_rounded,
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _complete();
                      }
                    },
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

class _OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
