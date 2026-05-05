import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/features/job_leads/data/models/job_lead_model.dart';
import 'package:swift_apply/app/features/job_leads/presentation/providers/job_lead_provider.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class JobLeadsScreen extends StatefulWidget {
  const JobLeadsScreen({super.key});

  @override
  State<JobLeadsScreen> createState() => _JobLeadsScreenState();
}

class _JobLeadsScreenState extends State<JobLeadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobLeadProvider>().load();
    });
  }

  Future<void> _pasteJob() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => const _PasteJobSheet(),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    await context.read<JobLeadProvider>().addFromPaste(text);
    if (mounted) showSnack(context, 'Job saved and contacts extracted');
  }

  void _apply(JobLead lead) {
    final recipient =
        lead.contactEmail.isNotEmpty ? lead.contactEmail : lead.contactPhone;
    final uri = Uri(
      path: AppRoute.home.path,
      queryParameters: {
        if (recipient.isNotEmpty) 'recipient': recipient,
        if (lead.company.isNotEmpty) 'company': lead.company,
        if (lead.position.isNotEmpty) 'position': lead.position,
      },
    );
    context.go(uri.toString());
  }

  Future<void> _openLeadDetails(JobLead lead) async {
    final updated = await showModalBottomSheet<JobLead>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => _LeadDetailsSheet(lead: lead, onApply: _apply),
    );

    if (updated == null || !mounted) return;
    await context.read<JobLeadProvider>().update(updated);
    if (mounted) showSnack(context, 'Job updated');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobLeadProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('Saved Jobs')),
          body: RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: provider.load,
            child: provider.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : provider.items.isEmpty
                    ? const _EmptyJobs()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                        itemCount: provider.visibleItems.length + 1,
                        separatorBuilder: (_, index) => index == 0
                            ? const SizedBox(height: 16)
                            : const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _LeadToolbar(provider: provider);
                          }
                          final lead = provider.visibleItems[index - 1];
                          return _JobLeadTile(
                            lead: lead,
                            onView: () => _openLeadDetails(lead),
                            onApply: () => _apply(lead),
                            onDelete: () async {
                              await provider.delete(lead);
                              if (context.mounted) {
                                showSnack(context, 'Job deleted');
                              }
                            },
                            onStatus: (status) {
                              provider.update(lead.copyWith(status: status));
                            },
                            onPriority: (priority) {
                              provider
                                  .update(lead.copyWith(priority: priority));
                            },
                          );
                        },
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            onPressed: _pasteJob,
            icon: const Icon(Icons.content_paste_rounded),
            label: const Text('Paste Job'),
          ),
        );
      },
    );
  }
}

Widget _sheetField(
  TextEditingController controller,
  String label,
  IconData icon, {
  int maxLines = 1,
  bool requiredValue = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppTheme.textSecondary, size: 20)
            : null,
      ),
      validator: (value) {
        if (!requiredValue) return null;
        if (value == null || value.trim().isEmpty) return '$label required';
        return null;
      },
    ),
  );
}

class _LeadToolbar extends StatelessWidget {
  const _LeadToolbar({required this.provider});

  final JobLeadProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (provider.dueFollowUps.isNotEmpty) ...[
          GlassCard(
            borderRadius: 14,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(
                  Icons.notification_important_rounded,
                  color: AppTheme.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${provider.dueFollowUps.length} follow-up due',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          onChanged: provider.setQuery,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Search saved jobs',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusChip(
                label: 'All',
                selected: provider.statusFilter == null,
                onTap: () => provider.setStatusFilter(null),
              ),
              for (final status in JobLeadStatus.values) ...[
                const SizedBox(width: 8),
                _StatusChip(
                  label: status.label,
                  selected: provider.statusFilter == status,
                  onTap: () => provider.setStatusFilter(status),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _JobLeadTile extends StatelessWidget {
  const _JobLeadTile({
    required this.lead,
    required this.onView,
    required this.onApply,
    required this.onDelete,
    required this.onStatus,
    required this.onPriority,
  });

  final JobLead lead;
  final VoidCallback onView;
  final VoidCallback onApply;
  final VoidCallback onDelete;
  final ValueChanged<JobLeadStatus> onStatus;
  final ValueChanged<JobLeadPriority> onPriority;

  @override
  Widget build(BuildContext context) {
    final contact = lead.contactEmail.isNotEmpty
        ? lead.contactEmail
        : lead.contactPhone.isNotEmpty
            ? lead.contactPhone
            : 'No contact extracted';
    return GlassCard(
      borderRadius: 14,
      onTap: onView,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lead.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _PriorityDot(priority: lead.priority),
              PopupMenuButton<String>(
                tooltip: 'Job actions',
                color: AppTheme.surface,
                iconColor: AppTheme.textSecondary,
                onSelected: (value) {
                  if (value == 'view') onView();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'view', child: Text('View / Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.person_search_rounded, text: contact),
              if (lead.location.isNotEmpty)
                _InfoPill(icon: Icons.location_on_rounded, text: lead.location),
              if (lead.salary.isNotEmpty)
                _InfoPill(icon: Icons.payments_rounded, text: lead.salary),
              if (lead.sourceUrl.isNotEmpty)
                const _InfoPill(icon: Icons.link_rounded, text: 'Link saved'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<JobLeadStatus>(
                  initialValue: lead.status,
                  dropdownColor: AppTheme.surface,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: JobLeadStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onStatus(value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<JobLeadPriority>(
                  initialValue: lead.priority,
                  dropdownColor: AppTheme.surface,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: JobLeadPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onPriority(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AccentButton(
            label: lead.hasContact ? 'Apply From This Job' : 'Use Job Details',
            icon: Icons.send_rounded,
            outlined: !lead.hasContact,
            onTap: onApply,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      selectedColor: AppTheme.accent.withValues(alpha: 0.22),
      backgroundColor: AppTheme.surfaceAlt,
      labelStyle: TextStyle(
        color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final JobLeadPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      JobLeadPriority.high => AppTheme.error,
      JobLeadPriority.medium => AppTheme.warning,
      JobLeadPriority.low => AppTheme.textMuted,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyJobs extends StatelessWidget {
  const _EmptyJobs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.work_history_rounded, color: AppTheme.textMuted, size: 52),
        SizedBox(height: 16),
        Text(
          'No saved jobs',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Paste a job post here. The app will remember it and extract email, phone, salary, and link locally.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _PasteJobSheet extends StatefulWidget {
  const _PasteJobSheet();

  @override
  State<_PasteJobSheet> createState() => _PasteJobSheetState();
}

class _PasteJobSheetState extends State<_PasteJobSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Paste Job Info'),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 8,
              maxLines: 14,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText:
                    'Paste job post, WhatsApp message, LinkedIn text, email, phone, salary, link...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            AccentButton(
              label: 'Save Job',
              icon: Icons.save_rounded,
              onTap: () => Navigator.pop(context, _controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadDetailsSheet extends StatefulWidget {
  final JobLead lead;
  final Function(JobLead) onApply;

  const _LeadDetailsSheet({
    required this.lead,
    required this.onApply,
  });

  @override
  State<_LeadDetailsSheet> createState() => _LeadDetailsSheetState();
}

class _LeadDetailsSheetState extends State<_LeadDetailsSheet> {
  late final TextEditingController company;
  late final TextEditingController position;
  late final TextEditingController location;
  late final TextEditingController salary;
  late final TextEditingController email;
  late final TextEditingController phone;
  late final TextEditingController url;
  late final TextEditingController notes;
  late final TextEditingController rawText;
  late JobLeadStatus status;
  late JobLeadPriority priority;

  @override
  void initState() {
    super.initState();
    company = TextEditingController(text: widget.lead.company);
    position = TextEditingController(text: widget.lead.position);
    location = TextEditingController(text: widget.lead.location);
    salary = TextEditingController(text: widget.lead.salary);
    email = TextEditingController(text: widget.lead.contactEmail);
    phone = TextEditingController(text: widget.lead.contactPhone);
    url = TextEditingController(text: widget.lead.sourceUrl);
    notes = TextEditingController(text: widget.lead.notes);
    rawText = TextEditingController(text: widget.lead.rawText);
    status = widget.lead.status;
    priority = widget.lead.priority;
  }

  @override
  void dispose() {
    company.dispose();
    position.dispose();
    location.dispose();
    salary.dispose();
    email.dispose();
    phone.dispose();
    url.dispose();
    notes.dispose();
    rawText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SectionLabel('Job Details'),
            const SizedBox(height: 14),
            _sheetField(position, 'Position', Icons.work_rounded),
            _sheetField(company, 'Company', Icons.business_rounded),
            Row(
              children: [
                Expanded(
                  child: _sheetField(
                    location,
                    'Location',
                    Icons.location_on_rounded,
                    requiredValue: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _sheetField(
                    salary,
                    'Salary',
                    Icons.payments_rounded,
                    requiredValue: false,
                  ),
                ),
              ],
            ),
            _sheetField(
              email,
              'Email',
              Icons.email_rounded,
              requiredValue: false,
            ),
            _sheetField(
              phone,
              'Phone',
              Icons.phone_rounded,
              requiredValue: false,
            ),
            _sheetField(
              url,
              'Job link',
              Icons.link_rounded,
              requiredValue: false,
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<JobLeadStatus>(
                    initialValue: status,
                    dropdownColor: AppTheme.surface,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: JobLeadStatus.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => status = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<JobLeadPriority>(
                    initialValue: priority,
                    dropdownColor: AppTheme.surface,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                    ),
                    items: JobLeadPriority.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => priority = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sheetField(
              notes,
              'Notes',
              Icons.note_alt_rounded,
              maxLines: 3,
              requiredValue: false,
            ),
            _sheetField(
              rawText,
              'Original shared text',
              Icons.description_rounded,
              maxLines: 8,
              requiredValue: false,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AccentButton(
                    label: 'Apply',
                    icon: Icons.send_rounded,
                    outlined: true,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onApply(widget.lead);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AccentButton(
                    label: 'Save',
                    icon: Icons.save_rounded,
                    onTap: () {
                      Navigator.pop(
                        context,
                        widget.lead.copyWith(
                          company: company.text.trim(),
                          position: position.text.trim(),
                          location: location.text.trim(),
                          salary: salary.text.trim(),
                          contactEmail: email.text.trim(),
                          contactPhone: phone.text.trim(),
                          sourceUrl: url.text.trim(),
                          notes: notes.text.trim(),
                          rawText: rawText.text.trim(),
                          status: status,
                          priority: priority,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
