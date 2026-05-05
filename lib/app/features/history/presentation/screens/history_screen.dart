import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/features/history/data/models/job_history_model.dart';
import 'package:swift_apply/app/features/history/presentation/providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              if (provider.items.isNotEmpty)
                IconButton(
                  tooltip: 'Clear history',
                  onPressed: () async {
                    await provider.clearAll();
                    if (context.mounted) showSnack(context, 'History cleared');
                  },
                  icon: const Icon(Icons.delete_sweep_rounded),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: provider.load,
            child: provider.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : provider.items.isEmpty
                ? const _EmptyHistory()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: provider.visibleItems.length + 1,
                    separatorBuilder: (_, index) => index == 0
                        ? const SizedBox(height: 16)
                        : const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _HistoryFilters(provider: provider);
                      }
                      final item = provider.visibleItems[index - 1];
                      return _HistoryTile(
                        item: item,
                        onDelete: () async {
                          await provider.delete(item.id ?? 0);
                          if (context.mounted) {
                            showSnack(context, 'History item deleted');
                          }
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({required this.provider});

  final HistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: provider.setQuery,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Search history',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _FilterChip(
              label: 'All',
              selected: provider.filter == 'all',
              onTap: () => provider.setFilter('all'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Email',
              selected: provider.filter == 'email',
              onTap: () => provider.setFilter('email'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'WhatsApp',
              selected: provider.filter == 'whatsapp',
              onTap: () => provider.setFilter('whatsapp'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      selectedColor: AppTheme.accent.withOpacity(0.22),
      backgroundColor: AppTheme.surfaceAlt,
      labelStyle: TextStyle(
        color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.onDelete});

  final JobHistory item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (item.isEmail ? AppTheme.accent : AppTheme.whatsappGreen)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.isEmail ? Icons.email_rounded : Icons.chat_rounded,
              color: item.isEmail ? AppTheme.accent : AppTheme.whatsappGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.recipient,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusChip(type: item.type),
                    if (item.cvName != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.cvName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.history_rounded, color: AppTheme.textMuted, size: 52),
        SizedBox(height: 16),
        Text(
          'No applications sent yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your email and WhatsApp activity will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
