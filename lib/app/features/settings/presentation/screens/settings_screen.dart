import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/features/home/presentation/providers/home_provider.dart';
import 'package:swift_apply/app/features/settings/data/models/settings_model.dart';
import 'package:swift_apply/app/features/settings/presentation/providers/settings_provider.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _smtpHost = TextEditingController();
  final _smtpPort = TextEditingController();
  final _subject = TextEditingController();
  final _emailTemplate = TextEditingController();
  final _whatsappTemplate = TextEditingController();
  final _targetPosition = TextEditingController();
  final _experience = TextEditingController();
  final _skills = TextEditingController();
  final _location = TextEditingController();
  final _countryCode = TextEditingController();
  final _waApiKey = TextEditingController();
  final _waPhoneId = TextEditingController();
  final _waBusinessId = TextEditingController();

  bool _filled = false;
  bool _autoAttachDefaultCv = true;
  bool _showGuidance = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SettingsProvider>();
      await provider.load();
      _fill(provider.settings);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _smtpHost.dispose();
    _smtpPort.dispose();
    _subject.dispose();
    _emailTemplate.dispose();
    _whatsappTemplate.dispose();
    _targetPosition.dispose();
    _experience.dispose();
    _skills.dispose();
    _location.dispose();
    _countryCode.dispose();
    _waApiKey.dispose();
    _waPhoneId.dispose();
    _waBusinessId.dispose();
    super.dispose();
  }

  void _fill(AppSettings? settings) {
    if (settings == null || _filled) return;
    _name.text = settings.senderName;
    _email.text = settings.senderEmail;
    _password.text = settings.emailPassword;
    _smtpHost.text = settings.smtpHost;
    _smtpPort.text = settings.smtpPort.toString();
    _subject.text = settings.emailSubject;
    _emailTemplate.text = settings.emailTemplate;
    _whatsappTemplate.text = settings.whatsappTemplate;
    _targetPosition.text = settings.targetPosition;
    _experience.text = settings.experienceYears;
    _skills.text = settings.skills;
    _location.text = settings.location;
    _countryCode.text = settings.defaultCountryCode;
    _autoAttachDefaultCv = settings.autoAttachDefaultCv;
    _waApiKey.text = settings.waApiKey;
    _waPhoneId.text = settings.waPhoneId;
    _waBusinessId.text = settings.waBusinessId;
    _filled = true;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final settings = AppSettings(
      senderName: _name.text.trim(),
      senderEmail: _email.text.trim(),
      emailPassword: _password.text,
      smtpHost: _smtpHost.text.trim(),
      smtpPort: int.tryParse(_smtpPort.text.trim()) ?? 587,
      emailSubject: _subject.text.trim(),
      emailTemplate: _emailTemplate.text,
      whatsappTemplate: _whatsappTemplate.text,
      targetPosition: _targetPosition.text.trim(),
      experienceYears: _experience.text.trim(),
      skills: _skills.text.trim(),
      location: _location.text.trim(),
      defaultCountryCode: _countryCode.text.trim(),
      autoAttachDefaultCv: _autoAttachDefaultCv,
      waApiKey: _waApiKey.text.trim(),
      waPhoneId: _waPhoneId.text.trim(),
      waBusinessId: _waBusinessId.text.trim(),
    );
    await context.read<SettingsProvider>().save(settings);
    if (mounted) await context.read<HomeProvider>().load();
    if (mounted) showSnack(context, 'Settings saved');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        _fill(provider.settings);
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('Settings')),
          body: provider.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      GlassCard(
                        onTap: () => context.push(AppRoute.cvLibrary.path),
                        borderRadius: 14,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.folder_copy_rounded,
                              color: AppTheme.accent,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'CV Library',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.textMuted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        'Setup Guidance',
                        trailing: InkWell(
                          onTap: () =>
                              setState(() => _showGuidance = !_showGuidance),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _showGuidance ? 'Hide' : 'Show Info',
                                  style: const TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  _showGuidance
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.accent,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_showGuidance) ...[
                        _guidanceCard(),
                        const SizedBox(height: 16),
                      ],
                      _section('Sender Profile'),
                      _field(_name, 'Name', Icons.person_rounded),
                      _field(_email, 'Email', Icons.email_rounded),
                      _field(
                        _password,
                        'App password',
                        Icons.lock_rounded,
                        obscure: true,
                        requiredValue: false,
                      ),
                      const SizedBox(height: 16),
                      _section('Career Profile'),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              _targetPosition,
                              'Target role',
                              Icons.work_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              _experience,
                              'Years',
                              Icons.timeline_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      _field(
                        _skills,
                        'Skills',
                        Icons.auto_awesome_rounded,
                        maxLines: 2,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              _location,
                              'Location',
                              Icons.location_on_rounded,
                              requiredValue: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              _countryCode,
                              'Country code',
                              Icons.phone_rounded,
                              requiredValue: false,
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Auto attach default CV',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        subtitle: const Text(
                          'Home will pick your default CV automatically.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        value: _autoAttachDefaultCv,
                        onChanged: (value) {
                          setState(() => _autoAttachDefaultCv = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _section('WhatsApp API'),
                      _field(
                        _waApiKey,
                        'WhatsApp API Key',
                        Icons.key_rounded,
                        requiredValue: false,
                        obscure: true,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              _waPhoneId,
                              'Phone ID',
                              Icons.phone_android_rounded,
                              requiredValue: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              _waBusinessId,
                              'Business ID',
                              Icons.business_center_rounded,
                              requiredValue: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _section('SMTP'),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _field(_smtpHost, 'Host', Icons.dns_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              _smtpPort,
                              'Port',
                              Icons.numbers_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _section('Templates'),
                      _field(_subject, 'Email subject', Icons.title_rounded),
                      _field(
                        _emailTemplate,
                        'Email template',
                        Icons.article_rounded,
                        maxLines: 8,
                      ),
                      _field(
                        _whatsappTemplate,
                        'WhatsApp template',
                        Icons.chat_rounded,
                        maxLines: 6,
                      ),
                      const Text(
                        'Placeholders: {name}, {email}, {position}, {company}, {experience}, {skills}, {location}',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AccentButton(
                        label: 'Save Settings',
                        icon: Icons.save_rounded,
                        isLoading: provider.saving,
                        onTap: provider.saving ? null : _save,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _section(String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionLabel(text, trailing: trailing),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    int maxLines = 1,
    bool requiredValue = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
        validator: (value) {
          if (!requiredValue) return null;
          if (value == null || value.trim().isEmpty) return '$label required';
          return null;
        },
      ),
    );
  }

  Widget _guidanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.accent.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _guidanceItem(
            'Email (Username) kia hai?',
            'Yeh aapka woh email address hai jis se aap applications send karengay (e.g., Gmail ya Outlook).',
            Icons.alternate_email_rounded,
          ),
          const Divider(height: 24, color: AppTheme.border),
          _guidanceItem(
            'App Password kia hai?',
            'Yeh aapka regular login password NAHI hai. Yeh ek special 16-digit code hota hai jo security ke liye generate kiya jata hai.',
            Icons.vpn_key_rounded,
          ),
          const Divider(height: 24, color: AppTheme.border),
          _guidanceItem(
            'Yeh kyun chahiye?',
            'Taake Swift Apply aapke behalf par emails securely bhej sake. App password use karne se aapka main account password safe rehta hai.',
            Icons.security_rounded,
          ),
          const Divider(height: 24, color: AppTheme.border),
          _guidanceItem(
            'Kahan se generate hoga?',
            '• Gmail: Google Account > Security > 2-Step Verification > App Passwords.\n• Outlook: Account Security > Advanced security options > App passwords.',
            Icons.stars_rounded,
          ),
        ],
      ),
    );
  }

  Widget _guidanceItem(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
