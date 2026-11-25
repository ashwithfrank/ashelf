import 'package:flutter/material.dart';

import 'core/settings.dart';
import 'core/theme.dart';
import 'data/library_repo.dart';
import 'ui/folder_screen.dart';
import 'ui/saved_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/update_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.instance.init();
  final repo = LibraryRepo.instance;
  await repo.init(); // local only, so the app opens instantly
  runApp(const AshelfApp());
  repo.refresh(); // then update from the network in the background
}

class AshelfApp extends StatelessWidget {
  const AshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Settings.instance,
      builder: (context, _) {
        final s = Settings.instance;
        return MaterialApp(
          title: 'Ashelf',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(s.accentColor),
          darkTheme: AppTheme.dark(s.accentColor, amoled: s.amoled),
          themeMode: s.themeMode,
          home: const Shell(),
        );
      },
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  final _pages = const [FolderScreen(), SavedScreen(), SettingsScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Settings.instance;
      final due = DateTime.now().millisecondsSinceEpoch - s.lastUpdateCheck > 86400000;
      if (mounted && s.autoUpdate && due) {
        s.markUpdateChecked();
        checkForUpdates(context, silent: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_library_outlined),
            selectedIcon: Icon(Icons.local_library),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
