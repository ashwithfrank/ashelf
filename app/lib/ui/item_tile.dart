import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../core/format.dart';
import '../data/library_repo.dart';
import '../data/models.dart';
import 'folder_screen.dart';

/// Downloads the file if needed, then opens it in the phone's PDF/file app.
Future<void> openItem(BuildContext context, LibItem item) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final file = await LibraryRepo.instance.download(item);
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      messenger.showSnackBar(SnackBar(
          content: Text(
              'No app on this phone can open ${item.ext.toUpperCase()} files.')));
    }
  } catch (_) {
    messenger.showSnackBar(const SnackBar(
        content: Text("Couldn't download the file. Check your connection and try again.")));
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item, this.showPath = false});
  final LibItem item;
  final bool showPath;

  static IconData _icon(String t) => switch (t) {
        'pdf' => Icons.picture_as_pdf_rounded,
        'doc' => Icons.description_rounded,
        'image' => Icons.image_rounded,
        'video' => Icons.movie_rounded,
        'audio' => Icons.audiotrack_rounded,
        _ => Icons.insert_drive_file_rounded,
      };

  static Color _color(String t) => switch (t) {
        'pdf' => Colors.red.shade400,
        'doc' => Colors.blue.shade400,
        'image' => Colors.green.shade500,
        'video' => Colors.purple.shade300,
        'audio' => Colors.orange.shade400,
        _ => Colors.blueGrey.shade300,
      };

  @override
  Widget build(BuildContext context) {
    final repo = LibraryRepo.instance;
    return item.isFolder ? _folder(context, repo) : _file(context, repo);
  }

  Widget _folder(BuildContext context, LibraryRepo repo) {
    return ListTile(
      leading: Icon(Icons.folder_rounded, color: Colors.amber.shade700, size: 32),
      title: Text(item.name),
      subtitle: Text('${repo.children(item.path).length} items'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FolderScreen(path: item.path)),
      ),
    );
  }

  Widget _file(BuildContext context, LibraryRepo repo) {
    final saved = repo.favs.contains(item.path);
    final done = repo.isDownloaded(item);
    final p = repo.progress[item.path];
    final where = item.parent.split('/').skip(2).join(' › ');
    final meta = [formatSize(item.size), if (showPath) where]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return ListTile(
      leading: Icon(_icon(item.type), color: _color(item.type), size: 32),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: meta.isEmpty
          ? null
          : Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () => openItem(context, item),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p != null)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(value: p, strokeWidth: 2.5),
            )
          else if (done)
            Icon(Icons.download_done_rounded,
                size: 20, color: Colors.green.shade600),
          if (saved)
            Icon(Icons.bookmark, size: 20, color: Colors.amber.shade700),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'save':
                  repo.toggleFav(item);
                  break;
                case 'share':
                  Share.share('${item.title}\n${item.url}');
                  break;
                case 'remove':
                  repo.deleteDownload(item);
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'save', child: Text(saved ? 'Remove from Saved' : 'Save')),
              const PopupMenuItem(value: 'share', child: Text('Share link')),
              if (done)
                const PopupMenuItem(value: 'remove', child: Text('Delete download')),
            ],
          ),
        ],
      ),
    );
  }
}
