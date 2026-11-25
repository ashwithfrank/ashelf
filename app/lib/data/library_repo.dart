import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config.dart';
import 'models.dart';

/// Loads the manifest, caches it for offline use, and manages downloads
/// and saved files.
class LibraryRepo extends ChangeNotifier {
  LibraryRepo._();
  static final instance = LibraryRepo._();

  List<LibItem> items = [];
  bool loading = true;
  bool fromCache = false;
  String? error;
  final Set<String> favs = {};
  final Map<String, double> progress = {};

  late Directory _dir;
  late SharedPreferences _prefs;

  File get _cacheFile => File('${_dir.path}/manifest.json');

  /// Fast, local-only start-up: opens storage and shows the cached manifest.
  Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();
    _prefs = await SharedPreferences.getInstance();
    favs.addAll(_prefs.getStringList('favs') ?? []);
    if (await _cacheFile.exists()) {
      try {
        _parse(await _cacheFile.readAsString());
        fromCache = true;
      } catch (_) {}
    }
    loading = items.isEmpty;
  }

  Future<void> refresh() async {
    if (items.isEmpty) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final res = await http
          .get(Uri.parse(Config.manifestUrl))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';
      final body = utf8.decode(res.bodyBytes);
      _parse(body);
      await _cacheFile.writeAsString(body);
      fromCache = false;
      error = null;
    } catch (_) {
      if (items.isNotEmpty) {
        fromCache = true;
      } else {
        error = "Couldn't load the library. Check your connection and try again.";
      }
    }
    loading = false;
    notifyListeners();
  }

  void _parse(String body) {
    items = (jsonDecode(body) as List)
        .map((e) => LibItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<LibItem> children(String path) {
    final list = items.where((i) => i.parent == path).toList();
    list.sort((a, b) {
      if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list;
  }

  List<LibItem> search(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return [];
    return items
        .where((i) =>
            !i.isFolder &&
            (i.title.toLowerCase().contains(s) ||
                i.path.toLowerCase().contains(s)))
        .take(100)
        .toList();
  }

  List<LibItem> saved() => items
      .where((i) => !i.isFolder && (favs.contains(i.path) || isDownloaded(i)))
      .toList();

  Future<void> toggleFav(LibItem item) async {
    if (!favs.remove(item.path)) favs.add(item.path);
    await _prefs.setStringList('favs', favs.toList());
    notifyListeners();
  }

  File localFile(LibItem item) => File('${_dir.path}/downloads/${item.path}');
  bool isDownloaded(LibItem item) => localFile(item).existsSync();

  Future<void> deleteDownload(LibItem item) async {
    final f = localFile(item);
    if (f.existsSync()) await f.delete();
    notifyListeners();
  }

  /// Downloads the file (if needed) and returns the local copy.
  Future<File> download(LibItem item) async {
    final file = localFile(item);
    if (file.existsSync()) return file;
    await file.parent.create(recursive: true);

    final client = http.Client();
    final tmp = File('${file.path}.part');
    final sink = tmp.openWrite();
    try {
      final res = await client.send(http.Request('GET', Uri.parse(item.dlUrl)));
      if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';
      final total = res.contentLength ?? item.size;
      var got = 0;
      progress[item.path] = 0;
      notifyListeners();
      await for (final chunk in res.stream) {
        sink.add(chunk);
        got += chunk.length;
        if (total > 0) {
          progress[item.path] = got / total;
          notifyListeners();
        }
      }
      await sink.close();
      await tmp.rename(file.path);
    } catch (e) {
      await sink.close().catchError((_) {});
      if (tmp.existsSync()) await tmp.delete();
      rethrow;
    } finally {
      client.close();
      progress.remove(item.path);
      notifyListeners();
    }
    return file;
  }

  int fileCount(String path) =>
      items.where((i) => !i.isFolder && i.path.startsWith('$path/')).length;

  int lastPage(LibItem i) => _prefs.getInt('page:${i.path}') ?? 1;
  void setLastPage(LibItem i, int page) => _prefs.setInt('page:${i.path}', page);

  Future<int> downloadsSize() async {
    final d = Directory('${_dir.path}/downloads');
    if (!await d.exists()) return 0;
    var total = 0;
    await for (final e in d.list(recursive: true)) {
      if (e is File) total += await e.length();
    }
    return total;
  }

  Future<void> clearDownloads() async {
    final d = Directory('${_dir.path}/downloads');
    if (await d.exists()) await d.delete(recursive: true);
    notifyListeners();
  }
}
