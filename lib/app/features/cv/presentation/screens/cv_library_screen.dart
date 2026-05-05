import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';
import 'package:swift_apply/app/features/cv/data/models/cv_file_model.dart';
import 'package:swift_apply/app/features/cv/presentation/providers/cv_provider.dart';

class CvLibraryScreen extends StatefulWidget {
  const CvLibraryScreen({super.key});

  @override
  State<CvLibraryScreen> createState() => _CvLibraryScreenState();
}

class _CvLibraryScreenState extends State<CvLibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CvProvider>().load();
    });
  }

  Future<void> _rename(CvFile cv) async {
    final controller = TextEditingController(text: cv.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename CV'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'CV name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty || !mounted) return;
    await context.read<CvProvider>().rename(cv, name);
    if (mounted) showSnack(context, 'CV renamed');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CvProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('CV Library')),
          body: RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: provider.load,
            child: provider.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  )
                : provider.items.isEmpty
                    ? const _EmptyCvLibrary()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                        itemCount: provider.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cv = provider.items[index];
                          return _CvTile(
                            cv: cv,
                            onRename: () => _rename(cv),
                            onDefault: () async {
                              await provider.setDefault(cv);
                              if (context.mounted) {
                                showSnack(context, 'Default CV updated');
                              }
                            },
                            onDelete: () async {
                              await provider.delete(cv);
                              if (context.mounted) {
                                showSnack(context, 'CV deleted');
                              }
                            },
                          );
                        },
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            onPressed: () async {
              final added = await provider.pickAndAddCv();
              if (!context.mounted || !added) return;
              showSnack(context, 'CV added');
            },
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Add CV'),
          ),
        );
      },
    );
  }
}

class _CvTile extends StatelessWidget {
  const _CvTile({
    required this.cv,
    required this.onRename,
    required this.onDefault,
    required this.onDelete,
  });

  final CvFile cv;
  final VoidCallback onRename;
  final VoidCallback onDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cv.isDefault ? 'Default CV' : cv.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        cv.isDefault ? AppTheme.accentAlt : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight:
                        cv.isDefault ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'CV actions',
            color: AppTheme.surface,
            iconColor: AppTheme.textSecondary,
            onSelected: (value) async {
              switch (value) {
                case 'share':
                  await SharePlus.instance.share(
                    ShareParams(files: [XFile(cv.path)], text: cv.name),
                  );
                  break;
                case 'rename':
                  onRename();
                  break;
                case 'default':
                  onDefault();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              if (!cv.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Text('Set default'),
                ),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCvLibrary extends StatelessWidget {
  const _EmptyCvLibrary();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.folder_copy_rounded, color: AppTheme.textMuted, size: 52),
        SizedBox(height: 16),
        Text(
          'No CVs added',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Add PDF, DOC, or DOCX files and attach them while sending email.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
