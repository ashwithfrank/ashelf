import 'package:flutter/material.dart';

import '../core/config.dart';
import '../data/library_repo.dart';
import 'item_tile.dart';
import 'message.dart';
import 'search_screen.dart';

class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key, this.path = Config.startPath});
  final String path;

  bool get _isStart => path == Config.startPath;

  @override
  Widget build(BuildContext context) {
    final repo = LibraryRepo.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isStart ? 'Ashelf' : path.split('/').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search files',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
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
            return Message(
                text: repo.error!, action: 'Try again', onTap: repo.refresh);
          }
          final kids = repo.children(path);
          if (kids.isEmpty) {
            return const Message(text: 'This folder is empty.');
          }
          return Column(
            children: [
              if (_isStart && repo.fromCache)
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text('Offline copy. Pull down to refresh.'),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: repo.refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: kids.length,
                    itemBuilder: (_, i) => ItemTile(item: kids[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
