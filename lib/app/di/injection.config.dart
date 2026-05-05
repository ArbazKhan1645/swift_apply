// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:swift_apply/app/core/database/db_service.dart' as _i117;
import 'package:swift_apply/app/features/applications/data/services/email_service.dart'
    as _i13;
import 'package:swift_apply/app/features/applications/data/services/whatsapp_service.dart'
    as _i736;
import 'package:swift_apply/app/features/cv/data/repositories/cv_repository.dart'
    as _i809;
import 'package:swift_apply/app/features/cv/presentation/providers/cv_provider.dart'
    as _i313;
import 'package:swift_apply/app/features/history/data/repositories/history_repository.dart'
    as _i360;
import 'package:swift_apply/app/features/history/presentation/providers/history_provider.dart'
    as _i29;
import 'package:swift_apply/app/features/home/presentation/providers/home_provider.dart'
    as _i406;
import 'package:swift_apply/app/features/job_leads/data/repositories/job_lead_repository.dart'
    as _i118;
import 'package:swift_apply/app/features/job_leads/presentation/providers/job_lead_provider.dart'
    as _i595;
import 'package:swift_apply/app/features/onboarding/data/repositories/onboarding_repository.dart'
    as _i781;
import 'package:swift_apply/app/features/settings/data/repositories/settings_repository.dart'
    as _i553;
import 'package:swift_apply/app/features/settings/presentation/providers/settings_provider.dart'
    as _i1066;
import 'package:swift_apply/app/routes/app_router.dart' as _i537;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i117.DatabaseService>(() => _i117.DatabaseService());
    gh.lazySingleton<_i13.EmailService>(() => _i13.EmailService());
    gh.lazySingleton<_i736.WhatsAppService>(() => _i736.WhatsAppService());
    gh.lazySingleton<_i781.OnboardingRepository>(
      () => _i781.OnboardingRepository(),
    );
    gh.lazySingleton<_i537.AppRouter>(() => _i537.AppRouter());
    gh.lazySingleton<_i809.CvRepository>(
      () => _i809.CvRepository(gh<_i117.DatabaseService>()),
    );
    gh.lazySingleton<_i360.HistoryRepository>(
      () => _i360.HistoryRepository(gh<_i117.DatabaseService>()),
    );
    gh.lazySingleton<_i118.JobLeadRepository>(
      () => _i118.JobLeadRepository(gh<_i117.DatabaseService>()),
    );
    gh.lazySingleton<_i553.SettingsRepository>(
      () => _i553.SettingsRepository(gh<_i117.DatabaseService>()),
    );
    gh.factory<_i313.CvProvider>(
      () => _i313.CvProvider(gh<_i809.CvRepository>()),
    );
    gh.factory<_i406.HomeProvider>(
      () => _i406.HomeProvider(
        gh<_i553.SettingsRepository>(),
        gh<_i13.EmailService>(),
        gh<_i736.WhatsAppService>(),
        gh<_i360.HistoryRepository>(),
        gh<_i809.CvRepository>(),
      ),
    );
    gh.factory<_i1066.SettingsProvider>(
      () => _i1066.SettingsProvider(gh<_i553.SettingsRepository>()),
    );
    gh.factory<_i29.HistoryProvider>(
      () => _i29.HistoryProvider(gh<_i360.HistoryRepository>()),
    );
    gh.factory<_i595.JobLeadProvider>(
      () => _i595.JobLeadProvider(
        gh<_i118.JobLeadRepository>(),
        gh<_i553.SettingsRepository>(),
      ),
    );
    return this;
  }
}
