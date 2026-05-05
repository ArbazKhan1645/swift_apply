import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/features/settings/data/models/settings_model.dart';
import 'package:swift_apply/app/features/settings/data/repositories/settings_repository.dart';

@injectable
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  AppSettings? _settings;
  bool _loading = false;
  bool _saving = false;

  AppSettings? get settings => _settings;
  bool get loading => _loading;
  bool get saving => _saving;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _settings = await _repository.getSettings();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(AppSettings settings) async {
    _saving = true;
    notifyListeners();
    await _repository.saveSettings(settings);
    _settings = settings;
    _saving = false;
    notifyListeners();
  }
}
