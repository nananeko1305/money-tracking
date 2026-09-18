import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../theme.dart';

/// The navigation drawer: section navigation, data import / export and the
/// language / theme settings.
class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onExport;
  final Future<void> Function() onImport;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onExport,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = scope.strings;
    final pal = palette(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _header(t, pal),
            const SizedBox(height: 8),
            _navTile(
              context,
              icon: Icons.account_balance_wallet,
              label: t.navBudget,
              selected: selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                onSelect(0);
              },
            ),
            _navTile(
              context,
              icon: Icons.bar_chart,
              label: t.navReports,
              selected: selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                onSelect(1);
              },
            ),
            const Divider(),
            _sectionLabel(t.dataSection),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(t.exportData),
              onTap: () {
                Navigator.pop(context);
                onExport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(t.importData),
              onTap: () {
                Navigator.pop(context);
                onImport();
              },
            ),
            const Divider(),
            _sectionLabel(t.settingsSection),
            _languageControl(context, scope, pal),
            _themeControl(context, scope, t, pal),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _VersionLabel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(AppStrings t, AppPalette pal) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [pal.green, pal.gold],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.show_chart, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            t.appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      );

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final pal = palette(context);
    return ListTile(
      leading: Icon(icon, color: selected ? pal.green : null),
      title: Text(label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? pal.green : null,
          )),
      selected: selected,
      selectedTileColor: pal.subtleFill,
      onTap: onTap,
    );
  }

  Widget _settingLabel(IconData icon, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  ButtonStyle _segStyle(AppPalette pal) => SegmentedButton.styleFrom(
        selectedBackgroundColor: pal.green,
        selectedForegroundColor: Colors.white,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        textStyle: const TextStyle(fontSize: 12.5),
      );

  Widget _languageControl(
      BuildContext context, AppScope scope, AppPalette pal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingLabel(Icons.language, scope.strings.language),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              style: _segStyle(pal),
              segments: const [
                ButtonSegment(value: 'sr', label: Text('Srpski')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {scope.localeCode},
              onSelectionChanged: (s) => scope.setLocale(s.first),
            ),
          ),
        ),
      ],
    );
  }

  Widget _themeControl(
      BuildContext context, AppScope scope, AppStrings t, AppPalette pal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _settingLabel(Icons.brightness_6, t.theme),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              style: _segStyle(pal),
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto, size: 17),
                  label: const Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode, size: 17),
                  label: Text(t.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode, size: 17),
                  label: Text(t.themeDark),
                ),
              ],
              selected: {scope.themeMode},
              onSelectionChanged: (s) => scope.setThemeMode(s.first),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows the installed app version, read from the platform package info.
class _VersionLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12, color: Theme.of(context).hintColor);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final label = info == null
            ? ''
            : 'v${info.version} (${info.buildNumber})';
        return Text(label, style: style);
      },
    );
  }
}
