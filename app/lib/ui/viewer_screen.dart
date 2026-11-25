import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../core/settings.dart';
import '../data/library_repo.dart';
import '../data/models.dart';
import 'item_tile.dart';
import 'message.dart';

/// In-app viewer for PDFs and images. Reads the saved copy when there is
/// one, otherwise streams the file live.
class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key, required this.item});
  final LibItem item;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  final _repo = LibraryRepo.instance;
  final _progress = ValueNotifier<double?>(null);
  PdfControllerPinch? _pdf;
  bool _night = Settings.instance.nightPdf;
  bool _loaded = false;
  Object? _error;

  LibItem get _item => widget.item;

  @override
  void initState() {
    super.initState();
    if (_item.type == 'pdf') {
      _pdf = PdfControllerPinch(
        document: _repo.isDownloaded(_item)
            ? PdfDocument.openFile(_repo.localFile(_item).path)
            : PdfDocument.openData(_fetch()),
        initialPage: _repo.lastPage(_item),
      );
    }
  }

  @override
  void dispose() {
    _pdf?.dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<Uint8List> _fetch() async {
    final client = http.Client();
    try {
      final res = await client.send(http.Request('GET', Uri.parse(_item.dlUrl)));
      if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';
      final total = res.contentLength ?? _item.size;
      final bytes = BytesBuilder(copy: false);
      var got = 0;
      await for (final chunk in res.stream) {
        bytes.add(chunk);
        got += chunk.length;
        if (total > 0) _progress.value = got / total;
      }
      _progress.value = null;
      return bytes.takeBytes();
    } finally {
      client.close();
    }
  }

  Future<void> _saveOffline() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _repo.download(_item);
      messenger.showSnackBar(const SnackBar(content: Text('Saved for offline reading.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text("Couldn't save the file. Check your connection and try again.")));
    }
  }

  Widget _downloadButton() {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final p = _repo.progress[_item.path];
        if (p != null) {
          return Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(value: p, strokeWidth: 2.5),
            ),
          );
        }
        if (_repo.isDownloaded(_item)) {
          return IconButton(
            icon: const Icon(Icons.download_done_rounded),
            tooltip: 'Saved for offline',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Already saved for offline reading.'))),
          );
        }
        return IconButton(
          icon: const Icon(Icons.download_for_offline_outlined),
          tooltip: 'Save for offline',
          onPressed: _saveOffline,
        );
      },
    );
  }

  Widget _body() {
    if (_item.type == 'image') {
      final img = _repo.isDownloaded(_item)
          ? Image.file(_repo.localFile(_item))
          : Image.network(
              _item.dlUrl,
              loadingBuilder: (_, child, p) => p == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) =>
                  const Message(text: "Couldn't load this image."),
            );
      return InteractiveViewer(minScale: 0.5, maxScale: 5, child: Center(child: img));
    }
    if (_error != null) {
      return Message(
        text: "Couldn't open this PDF. Check your connection, or open it in another app.",
        action: 'Open in another app',
        onTap: () => openExternal(context, _item),
      );
    }
    final viewer = PdfViewPinch(
      controller: _pdf!,
      onPageChanged: (p) => _repo.setLastPage(_item, p),
      onDocumentLoaded: (_) => setState(() => _loaded = true),
      onDocumentError: (e) => setState(() => _error = e),
    );
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: _night
              ? const ColorFilter.matrix(<double>[
                  -1, 0, 0, 0, 255, //
                  0, -1, 0, 0, 255, //
                  0, 0, -1, 0, 255, //
                  0, 0, 0, 1, 0,
                ])
              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
          child: viewer,
        ),
        ValueListenableBuilder<double?>(
          valueListenable: _progress,
          builder: (_, v, __) =>
              v == null ? const SizedBox.shrink() : LinearProgressIndicator(value: v),
        ),
        if (_loaded)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(170),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _pdf!.pageListenable,
                    builder: (_, page, __) => Text(
                      '$page / ${_pdf!.pagesCount ?? ''}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (_item.type == 'pdf')
            IconButton(
              icon: Icon(_night ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              tooltip: _night ? 'Light pages' : 'Dark pages',
              onPressed: () => setState(() => _night = !_night),
            ),
          _downloadButton(),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'external') openExternal(context, _item);
              if (v == 'share') Share.share('${_item.title}\n${_item.url}');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'external', child: Text('Open in another app')),
              PopupMenuItem(value: 'share', child: Text('Share link')),
            ],
          ),
        ],
      ),
      body: _body(),
    );
  }
}
