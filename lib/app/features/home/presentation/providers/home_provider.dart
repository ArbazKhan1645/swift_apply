import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/features/applications/data/services/email_service.dart';
import 'package:swift_apply/app/features/applications/data/services/whatsapp_service.dart';
import 'package:swift_apply/app/features/cv/data/models/cv_file_model.dart';
import 'package:swift_apply/app/features/cv/data/repositories/cv_repository.dart';
import 'package:swift_apply/app/features/history/data/models/job_history_model.dart';
import 'package:swift_apply/app/features/history/data/repositories/history_repository.dart';
import 'package:swift_apply/app/features/settings/data/models/settings_model.dart';
import 'package:swift_apply/app/features/settings/data/repositories/settings_repository.dart';

enum SendType { auto, whatsapp, email }

class SendResult {
  const SendResult({required this.message, this.isError = false});

  final String message;
  final bool isError;
}

@injectable
class HomeProvider extends ChangeNotifier {
  HomeProvider(
    this._settingsRepository,
    this._emailService,
    this._whatsAppService,
    this._historyRepository,
    this._cvRepository,
  );

  final SettingsRepository _settingsRepository;
  final EmailService _emailService;
  final WhatsAppService _whatsAppService;
  final HistoryRepository _historyRepository;
  final CvRepository _cvRepository;

  AppSettings? _settings;
  CvFile? _selectedCv;
  bool _loading = true;
  bool _sending = false;
  Map<String, int> _stats = const {};

  AppSettings? get settings => _settings;
  CvFile? get selectedCv => _selectedCv;
  bool get loading => _loading;
  bool get sending => _sending;
  Map<String, int> get stats => _stats;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    _settings = await _settingsRepository.getSettings();
    if (_settings?.autoAttachDefaultCv ?? false) {
      _selectedCv = await _cvRepository.getDefaultCv();
    }
    _stats = await _historyRepository.getStats();
    _loading = false;
    notifyListeners();
  }

  String detectRecipientType(String value) {
    if (WhatsAppService.isValidEmail(value)) return 'email';
    if (WhatsAppService.isValidPhone(value)) return 'whatsapp';
    return 'unknown';
  }

  bool isEmailMode(String value) {
    final recipient = value.trim();
    return recipient.isEmpty || detectRecipientType(recipient) == 'email';
  }

  void selectCv(CvFile cv) {
    _selectedCv = cv;
    notifyListeners();
  }

  void clearCv() {
    _selectedCv = null;
    notifyListeners();
  }

  Future<SendResult> sendApplication(
    String recipientValue, {
    String? company,
    String? position,
  }) async {
    final settings = _settings;
    if (settings == null) {
      return const SendResult(
        message: 'Settings are still loading. Please try again.',
        isError: true,
      );
    }

    final recipient = recipientValue.trim();
    final detectedType = detectRecipientType(recipient);
    if (detectedType == 'unknown') {
      return const SendResult(
        message: 'Enter a valid email or phone number',
        isError: true,
      );
    }

    _sending = true;
    notifyListeners();

    try {
      if (detectedType == 'whatsapp') {
        final isApi = settings.waApiKey.isNotEmpty && settings.waPhoneId.isNotEmpty;
        await _whatsAppService.openWhatsApp(
          settings: settings,
          phoneNumber: recipient,
          company: company,
          position: position,
        );
        await _historyRepository.addEntry(
          JobHistory(
            recipient: recipient,
            type: 'whatsapp',
            note: _buildHistoryNote(company, position),
            sentAt: DateTime.now(),
          ),
        );
        await _refreshStats();
        return SendResult(
          message: isApi ? 'WhatsApp message sent' : 'WhatsApp opened',
        );
      }

      final isSmtp =
          settings.senderEmail.isNotEmpty && settings.emailPassword.isNotEmpty;

      await _emailService.sendEmail(
        settings: settings,
        toEmail: recipient,
        cvPath: _selectedCv?.path,
        company: company,
        position: position,
      );
      await _historyRepository.addEntry(
        JobHistory(
          recipient: recipient,
          type: 'email',
          cvName: _selectedCv?.name,
          note: _buildHistoryNote(company, position),
          sentAt: DateTime.now(),
        ),
      );
      _selectedCv = null;
      await _refreshStats();
      return SendResult(
        message: isSmtp ? 'Email sent successfully' : 'Email client opened',
      );
    } catch (e) {
      return SendResult(message: e.toString(), isError: true);
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> _refreshStats() async {
    _stats = await _historyRepository.getStats();
  }

  String? _buildHistoryNote(String? company, String? position) {
    final parts = [
      if (company != null && company.trim().isNotEmpty)
        'Company: ${company.trim()}',
      if (position != null && position.trim().isNotEmpty)
        'Role: ${position.trim()}',
    ];
    return parts.isEmpty ? null : parts.join(' | ');
  }
}
