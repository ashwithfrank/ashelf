import 'package:flutter/material.dart';

import '../core/config.dart';
import '../core/settings.dart';
import '../data/library_repo.dart';
import '../data/models.dart';
import 'item_tile.dart';
import 'message.dart';
import 'search_screen.dart';

/// Shows a folder. At the root it shows the courses (BCA, BCOM, ...) as cards.
class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key, this.path = Config.rootPath});
  final String path;

  bool get _isRoot => path == Config.rootPath;

  @override
  Widget build(BuildContext context) {
    final repo = LibraryRepo.instance;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRoot ? 'Ashelf' : path.split('/').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search files',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          if (_isRoot)
            IconButton(
              icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: 'Switch theme',
              onPressed: () => Settings.instance
                  .setThemeMode(dark ? ThemeMode.light : ThemeMode.dark),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          if (repo.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (repo.error != null) {
            return Message(text: repo.error!, action: 'Try again', onTap: repo.refresh);
          }
          final kids = repo.children(path);
          if (kids.isEmpty) {
            return const Message(text: 'This folder is empty.');
          }
          return Column(
            children: [
              if (_isRoot && repo.fromCache)
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text('Offline copy. Pull down to refresh.'),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: repo.refresh,
                  child: _isRoot ? _courses(kids) : _list(kids),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _list(List<LibItem> kids) => ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: kids.length,
        itemBuilder: (_, i) => ItemTile(item: kids[i]),
      );

  Widget _courses(List<LibItem> kids) {
    final folders = kids.where((k) => k.isFolder).toList();
    final files = kids.where((k) => !k.isFolder).toList();
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [for (final f in folders) _CourseCard(item: f)],
        ),
        for (final f in files) ItemTile(item: f),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.item});
  final LibItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = LibraryRepo.instance.fileCount(item.path);
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FolderScreen(path: item.path)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.school_outlined, color: scheme.onPrimaryContainer),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                  Text('$count files', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
