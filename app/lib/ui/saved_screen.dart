import 'package:flutter/material.dart';

import '../data/library_repo.dart';
import 'item_tile.dart';
import 'message.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = LibraryRepo.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          final list = repo.saved();
          if (list.isEmpty) {
            return const Message(
              text:
                  'Nothing saved yet. Open a file to keep it for offline use, or save it from its menu.',
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => ItemTile(item: list[i], showPath: true),
          );
        },
      ),
    );
  }
}
