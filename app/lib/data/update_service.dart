import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../core/config.dart';

class UpdateInfo {
  UpdateInfo({
    required this.current,
    required this.latest,
    required this.available,
    this.notes = '',
    this.url = '',
  });
  final String current;
  final String latest;
  final bool available;
  final String notes;
  final String url;
}

/// Compares the installed version with the latest GitHub release.
class UpdateService {
  static Future<UpdateInfo> check() async {
    final pkg = await PackageInfo.fromPlatform();
    final res = await http.get(
      Uri.parse(Config.latestReleaseApi),
      headers: {'Accept': 'application/vnd.github+json'},
    ).timeout(const Duration(seconds: 15));

    // 404 = no release published yet
    if (res.statusCode == 404) {
      return UpdateInfo(current: pkg.version, latest: pkg.version, available: false);
    }
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final tag = (j['tag_name'] as String).replaceFirst(RegExp(r'^[vV]'), '');
    final assets = ((j['assets'] ?? []) as List).cast<Map<String, dynamic>>();
    final apks = assets.where((a) => (a['name'] as String).endsWith('.apk'));
    final url = apks.isNotEmpty
        ? apks.first['browser_download_url'] as String
        : j['html_url'] as String;
    return UpdateInfo(
      current: pkg.version,
      latest: tag,
      available: _newer(tag, pkg.version),
      notes: (j['body'] ?? '') as String,
      url: url,
    );
  }

  static bool _newer(String a, String b) {
    List<int> parts(String v) => v
        .split('+')
        .first
        .split('.')
        .map((s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final x = parts(a), y = parts(b);
    for (var i = 0; i < 3; i++) {
      final xi = i < x.length ? x[i] : 0;
      final yi = i < y.length ? y[i] : 0;
      if (xi != yi) return xi > yi;
    }
    return false;
  }
}
