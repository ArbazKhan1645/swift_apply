import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swift_apply/app/core/presentation/widgets/common_widget.dart';
import 'package:swift_apply/app/core/theme/app_theme.dart';

import 'dart:io';

import 'package:swift_apply/app/features/cv/data/models/cv_file_model.dart';
import 'package:swift_apply/app/features/cv/data/repositories/cv_repository.dart';

class CvPickerSheet extends StatefulWidget {
  final CvFile? selectedCv;
  final void Function(CvFile cv) onSelected;

  const CvPickerSheet({super.key, this.selectedCv, required this.onSelected});

  @override
  State<CvPickerSheet> createState() => _CvPickerSheetState();
}

class _CvPickerSheetState extends State<CvPickerSheet> {
  List<CvFile> _cvs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cvs = await context.read<CvRepository>().getAllCvs();
    if (mounted) {
      setState(() {
        _cvs = cvs;
        _loading = false;
      });
    }
  }

  Future<void> _shareCv(CvFile cv) async {
    final file = File(cv.path);
    if (await file.exists()) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(cv.path)], text: cv.name),
      );
    } else {
      if (mounted) {
        showSnack(context, 'File not found on device', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select CV to attach',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          else if (_cvs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    color: AppTheme.textMuted,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No CVs added yet.\nGo to Settings → CV Library to add.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cvs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final cv = _cvs[i];
                  final selected = widget.selectedCv?.id == cv.id;
                  return GestureDetector(
                    onTap: () {
                      widget.onSelected(cv);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.accentGlow
                            : AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppTheme.accent : AppTheme.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: AppTheme.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cv.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (cv.isDefault)
                                  const Text(
                                    'Default',
                                    style: TextStyle(
                                      color: AppTheme.accentAlt,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_rounded, size: 18),
                            color: AppTheme.textSecondary,
                            onPressed: () => _shareCv(cv),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.accent,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
