import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:swift_apply/app/features/job_leads/presentation/providers/job_lead_provider.dart';
import 'package:swift_apply/app/routes/app_router.dart';

class ShareIntentListener extends StatefulWidget {
  const ShareIntentListener({super.key, required this.child});

  final Widget child;

  @override
  State<ShareIntentListener> createState() => _ShareIntentListenerState();
}

class _ShareIntentListenerState extends State<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _subscription;
  String? _lastPayload;

  @override
  void initState() {
    super.initState();
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handleSharedMedia,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      await _handleSharedMedia(initial);
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSharedMedia(List<SharedMediaFile> files) async {
    final payload = files
        .where((file) {
          return file.type == SharedMediaType.text ||
              file.type == SharedMediaType.url ||
              (file.mimeType?.startsWith('text/') ?? false);
        })
        .map(
          (file) => file.message == null || file.message!.trim().isEmpty
              ? file.path
              : '${file.message}\n${file.path}',
        )
        .join('\n')
        .trim();

    if (!mounted || payload.isEmpty || payload == _lastPayload) return;
    _lastPayload = payload;

    await context.read<JobLeadProvider>().addFromPaste(payload);
    if (!mounted) return;
    context.go(AppRoute.jobs.path);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
