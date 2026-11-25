import 'package:flutter/material.dart';

import '../data/library_repo.dart';
import 'item_tile.dart';
import 'message.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final repo = LibraryRepo.instance;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search notes and question papers',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _q = v),
        ),
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          if (_q.trim().isEmpty) {
            return const Message(text: 'Type a subject, unit or year.');
          }
          final results = repo.search(_q);
          if (results.isEmpty) {
            return Message(text: 'No files match "$_q".');
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) => ItemTile(item: results[i], showPath: true),
          );
        },
      ),
    );
  }
}
