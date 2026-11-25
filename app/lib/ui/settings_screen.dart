import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/settings.dart';
import '../data/library_repo.dart';
import 'about_screen.dart';
import 'update_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _s = Settings.instance;
  final _repo = LibraryRepo.instance;

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );

  Future<void> _clearDownloads() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear downloads?'),
        content: const Text('Saved files are removed from this phone. You can download them again anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.clearDownloads();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: _s,
        builder: (context, _) => ListView(
          children: [
            _section('Appearance'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
                ],
                selected: {_s.themeMode},
                onSelectionChanged: (v) => _s.setThemeMode(v.first),
              ),
            ),
            SwitchListTile(
              title: const Text('Pure black dark theme'),
              subtitle: const Text('Saves battery on OLED screens'),
              value: _s.amoled,
              onChanged: _s.setAmoled,
            ),
            ListTile(
              title: const Text('Accent colour'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 12,
                  children: [
                    for (var i = 0; i < Settings.accents.length; i++)
                      GestureDetector(
                        onTap: () => _s.setAccent(i),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Settings.accents[i],
                          child: _s.accent == i
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _section('Reading'),
            SwitchListTile(
              title: const Text('Open files inside Ashelf'),
              subtitle: const Text('PDFs and images use the built-in viewer'),
              value: _s.openInApp,
              onChanged: _s.setOpenInApp,
            ),
            SwitchListTile(
              title: const Text('Dark PDF pages'),
              subtitle: const Text('Start PDFs in night mode. You can also toggle it per file.'),
              value: _s.nightPdf,
              onChanged: _s.setNightPdf,
            ),
            _section('Library'),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh library'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await _repo.refresh();
                messenger.showSnackBar(SnackBar(
                    content: Text(_repo.fromCache
                        ? "Couldn't reach the library. Showing the saved copy."
                        : 'Library updated.')));
              },
            ),
            FutureBuilder<int>(
              future: _repo.downloadsSize(),
              builder: (_, snap) => ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear downloads'),
                subtitle: Text(snap.hasData
                    ? (snap.data! > 0 ? '${formatSize(snap.data!)} used' : 'Nothing downloaded')
                    : 'Calculating...'),
                onTap: _clearDownloads,
              ),
            ),
            _section('Updates'),
            SwitchListTile(
              title: const Text('Check for updates automatically'),
              subtitle: const Text('Once a day when you open the app'),
              value: _s.autoUpdate,
              onChanged: _s.setAutoUpdate,
            ),
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: const Text('Check for updates now'),
              onTap: () => checkForUpdates(context),
            ),
            _section('About'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Ashelf'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
