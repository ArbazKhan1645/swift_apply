import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/features/cv/presentation/widgets/cv_picker_sheet.dart';
import 'package:swift_apply/app/features/history/data/models/job_history_model.dart';
import 'package:swift_apply/app/features/home/presentation/providers/home_provider.dart';
import 'package:swift_apply/app/features/job_leads/data/models/job_lead_model.dart';
import 'package:swift_apply/app/features/job_leads/presentation/providers/job_lead_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _recipientController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SendType _sendType = SendType.auto;
  String _lastRouteQuery = '';
  String? _clipboardContent;
  bool _showSuccessOverlay = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    WidgetsBinding.instance.addObserver(this);
    _checkClipboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillFromRoute();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;
    final text = data!.text!.trim();
    if (text == _clipboardContent) return;

    // Basic heuristic for job info
    final hasEmail = text.contains('@');
    final hasPhone = RegExp(r'\d{7,}').hasMatch(text);
    if (hasEmail || hasPhone) {
      setState(() => _clipboardContent = text);
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _animController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _magicFill() {
    if (_clipboardContent == null) return;
    final lead = JobLeadProvider.parseJobText(
      _clipboardContent!,
      fallbackPosition:
          context.read<HomeProvider>().settings?.targetPosition ?? '',
    );
    _recipientController.text = lead.contactEmail.isNotEmpty
        ? lead.contactEmail
        : lead.contactPhone;
    _companyController.text = lead.company;
    _positionController.text = lead.position;
    setState(() => _clipboardContent = null);
    showSnack(context, 'Magic Fill applied!');
  }

  String _detectType(String value) {
    return context.read<HomeProvider>().detectRecipientType(value.trim());
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await context.read<HomeProvider>().sendApplication(
      _recipientController.text,
      company: _companyController.text,
      position: _positionController.text,
    );
    if (!mounted) return;

    if (mounted) {
      if (!result.isError) {
        _recipientController.clear();
        _companyController.clear();
        setState(() => _showSuccessOverlay = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showSuccessOverlay = false);
        });
      } else {
        showSnack(context, result.message, isError: true);
      }
    }
  }

  void _pickCv() {
    final provider = context.read<HomeProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CvPickerSheet(
        selectedCv: provider.selectedCv,
        onSelected: provider.selectCv,
      ),
    );
  }

  String get _recipientHint {
    switch (_sendType) {
      case SendType.whatsapp:
        return '+971 50 123 4567';
      case SendType.email:
        return 'hr@company.ae';
      case SendType.auto:
        return 'Phone number or email address';
    }
  }

  IconData get _recipientIcon {
    final value = _recipientController.text.trim();
    if (value.isEmpty) return Icons.person_outline_rounded;
    final type = _detectType(value);
    if (type == 'email') return Icons.email_outlined;
    if (type == 'whatsapp') return Icons.chat_outlined;
    return Icons.person_outline_rounded;
  }

  Color get _sendButtonColor {
    final value = _recipientController.text.trim();
    if (value.isEmpty) return AppTheme.accent;
    final type = _detectType(value);
    if (type == 'whatsapp') return AppTheme.whatsappGreen;
    if (type == 'email') return AppTheme.accent;
    return AppTheme.accent;
  }

  String get _sendButtonLabel {
    final value = _recipientController.text.trim();
    if (value.isEmpty) return 'Send Application';
    final type = _detectType(value);
    if (type == 'whatsapp') return 'Open WhatsApp';
    if (type == 'email') return 'Send Email';
    return 'Send Application';
  }

  IconData get _sendButtonIcon {
    final value = _recipientController.text.trim();
    if (value.isEmpty) return Icons.send_rounded;
    final type = _detectType(value);
    if (type == 'whatsapp') return Icons.chat_rounded;
    if (type == 'email') return Icons.send_rounded;
    return Icons.send_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnim,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildStatsRow(provider),
                          const SizedBox(height: 16),
                          if (_clipboardContent != null)
                            _buildMagicFillBanner(),
                          _buildProfileStrip(provider),
                          const SizedBox(height: 24),
                          _buildSendCard(provider),
                          const SizedBox(height: 20),
                          if (provider.isEmailMode(_recipientController.text))
                            _buildCvSelector(provider),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedStatusOverlay(
                show: _showSuccessOverlay,
                title: 'Sent Successfully!',
                subtitle: 'Your application is on its way.',
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  void _prefillFromRoute() {
    final uri = GoRouterState.of(context).uri;
    if (uri.query == _lastRouteQuery) return;
    final params = uri.queryParameters;
    _recipientController.text =
        params['recipient'] ?? _recipientController.text;
    _companyController.text = params['company'] ?? _companyController.text;
    _positionController.text = params['position'] ?? _positionController.text;
    _lastRouteQuery = uri.query;
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: false,
      backgroundColor: AppTheme.bg,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Swift',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Apply',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Send applications instantly',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(HomeProvider provider) {
    return Row(
      children: [
        _StatCard(
          label: 'Total Sent',
          value: '${provider.stats['total'] ?? 0}',
          icon: Icons.rocket_launch_rounded,
          color: AppTheme.accent,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Emails',
          value: '${provider.stats['emails'] ?? 0}',
          icon: Icons.email_rounded,
          color: AppTheme.accentAlt,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'WhatsApp',
          value: '${provider.stats['whatsapps'] ?? 0}',
          icon: Icons.chat_rounded,
          color: AppTheme.whatsappGreen,
        ),
      ],
    );
  }

  Widget _buildSendCard(HomeProvider provider) {
    if (_positionController.text.isEmpty) {
      _positionController.text = provider.settings?.targetPosition ?? '';
    }
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Quick Send'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Recipient',
                hintText: _recipientHint,
                prefixIcon: Icon(
                  _recipientIcon,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: _recipientController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        color: AppTheme.textMuted,
                        onPressed: () {
                          _recipientController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a phone or email';
                }
                final type = _detectType(v);
                if (type == 'unknown') {
                  return 'Enter a valid email or phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _companyController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Company',
                      hintText: 'Company name',
                      prefixIcon: Icon(
                        Icons.business_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _positionController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      hintText: 'Target role',
                      prefixIcon: Icon(
                        Icons.work_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTypeIndicator(),
            const SizedBox(height: 16),
            AccentButton(
              label: _sendButtonLabel,
              icon: _sendButtonIcon,
              color: _sendButtonColor,
              isLoading: provider.sending,
              onTap: provider.sending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagicFillBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderColor: AppTheme.accentAlt.withOpacity(0.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentAlt.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accentAlt,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job detected in clipboard!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Tap to Magic Fill the fields.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _magicFill,
              style: TextButton.styleFrom(foregroundColor: AppTheme.accentAlt),
              child: const Text('MAGIC FILL'),
            ),
            IconButton(
              onPressed: () => setState(() => _clipboardContent = null),
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStrip(HomeProvider provider) {
    final settings = provider.settings;
    if (settings == null) return const SizedBox.shrink();

    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accentAlt.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: AppTheme.accentAlt,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.targetPosition,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${settings.experienceYears} yrs | ${settings.skills}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator() {
    final value = _recipientController.text.trim();
    if (value.isEmpty) return const SizedBox.shrink();
    final type = _detectType(value);
    if (type == 'unknown') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warning,
              size: 14,
            ),
            SizedBox(width: 6),
            Text(
              'Not a valid email or phone number',
              style: TextStyle(color: AppTheme.warning, fontSize: 12),
            ),
          ],
        ),
      );
    }
    final isWhatsApp = type == 'whatsapp';
    final color = isWhatsApp ? AppTheme.whatsappGreen : AppTheme.accent;
    final settings = context.read<HomeProvider>().settings;

    String label = '';
    if (isWhatsApp) {
      final isApi =
          settings?.waApiKey.isNotEmpty == true &&
          settings?.waPhoneId.isNotEmpty == true;
      label = isApi
          ? 'Will send direct WhatsApp message (API)'
          : 'Will open WhatsApp (External)';
    } else {
      final isSmtp =
          settings?.senderEmail.isNotEmpty == true &&
          settings?.emailPassword.isNotEmpty == true;
      label = isSmtp
          ? 'Will send direct Email (SMTP)'
          : 'Will open Email app (External)';
    }
    final icon = isWhatsApp ? Icons.chat_rounded : Icons.email_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvSelector(HomeProvider provider) {
    final selectedCv = provider.selectedCv;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Attach CV'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickCv,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedCv != null
                      ? AppTheme.accent.withValues(alpha: 0.5)
                      : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      selectedCv != null
                          ? Icons.picture_as_pdf_rounded
                          : Icons.add_circle_outline_rounded,
                      color: AppTheme.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedCv?.name ?? 'Choose CV to attach',
                      style: TextStyle(
                        color: selectedCv != null
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: selectedCv != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (selectedCv != null)
                    GestureDetector(
                      onTap: provider.clearCv,
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
