import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_apply/app/core/presentation/share/share_intent_listener.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/di/injection.dart';
import 'package:swift_apply/app/features/cv/presentation/providers/cv_provider.dart';
import 'package:swift_apply/app/features/history/presentation/providers/history_provider.dart';
import 'package:swift_apply/app/features/home/presentation/providers/home_provider.dart';
import 'package:swift_apply/app/features/cv/data/repositories/cv_repository.dart';
import 'package:swift_apply/app/features/job_leads/presentation/providers/job_lead_provider.dart';
import 'package:swift_apply/app/features/settings/presentation/providers/settings_provider.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class SwiftApplyApp extends StatelessWidget {
  const SwiftApplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CvRepository>.value(value: getIt<CvRepository>()),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => getIt<HomeProvider>()..load(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => getIt<HistoryProvider>(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => getIt<SettingsProvider>(),
        ),
        ChangeNotifierProvider<CvProvider>(create: (_) => getIt<CvProvider>()),
        ChangeNotifierProvider<JobLeadProvider>(
          create: (_) => getIt<JobLeadProvider>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Swift Apply',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: getIt<AppRouter>().router,
        builder: (context, child) {
          return ShareIntentListener(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
