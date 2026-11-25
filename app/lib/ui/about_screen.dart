import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config.dart';
import 'update_dialog.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _row(IconData icon, String title, String value, {String? url}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      onTap: url == null
          ? null
          : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/icon/icon.png', width: 88, height: 88),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Ashelf', style: text.headlineSmall)),
          const SizedBox(height: 4),
          Center(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, s) => Text(
                s.hasData ? 'Version ${s.data!.version} (${s.data!.buildNumber})' : '',
                style: text.bodyMedium,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
            child: Text(
              'A study library for notes, question papers and records, with offline reading.',
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 32),
          _row(Icons.person_outline, 'Developer', 'Ashwith Frank', url: Config.portfolioUrl),
          _row(Icons.auto_awesome_outlined, 'Powered by', 'AlphaOmega Studio'),
          _row(Icons.code, 'App source code', 'github.com/ashwithfrank/ashelf',
              url: Config.appRepoUrl),
          _row(Icons.folder_copy_outlined, 'Library files', 'github.com/ashwithfrank/ashelf-library',
              url: Config.libraryRepoUrl),
          ListTile(
            leading: const Icon(Icons.system_update_outlined),
            title: const Text('Check for updates'),
            onTap: () => checkForUpdates(context),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Open-source licences'),
            onTap: () => showLicensePage(context: context, applicationName: 'Ashelf'),
          ),
          const SizedBox(height: 16),
          Center(child: Text('© 2026 AlphaOmega Studio', style: text.bodySmall)),
        ],
      ),
    );
  }
}
