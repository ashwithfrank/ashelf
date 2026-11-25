import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/update_service.dart';

Future<void> showUpdateDialog(BuildContext context, UpdateInfo info) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Update available'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${info.latest} is ready. You have ${info.current}.'),
            if (info.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(info.notes.trim(), maxLines: 8, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
        FilledButton(
          onPressed: () {
            launchUrl(Uri.parse(info.url), mode: LaunchMode.externalApplication);
            Navigator.pop(ctx);
          },
          child: const Text('Download'),
        ),
      ],
    ),
  );
}

/// Checks GitHub for a newer release. With [silent], only speaks up if an
/// update exists.
Future<void> checkForUpdates(BuildContext context, {bool silent = false}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final info = await UpdateService.check();
    if (!context.mounted) return;
    if (info.available) {
      await showUpdateDialog(context, info);
    } else if (!silent) {
      messenger.showSnackBar(
          SnackBar(content: Text("You're up to date (version ${info.current}).")));
    }
  } catch (_) {
    if (!silent) {
      messenger.showSnackBar(const SnackBar(
          content: Text("Couldn't check for updates. Try again later.")));
    }
  }
}
