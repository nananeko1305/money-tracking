import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_scope.dart';
import 'l10n/strings.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'services/backup.dart';
import 'services/storage.dart';
import 'theme.dart';

const _prefLocale = 'settings_locale';
const _prefThemeMode = 'settings_theme_mode';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  String _localeCode = 'sr';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localeCode = prefs.getString(_prefLocale) ?? 'sr';
      _themeMode = _themeModeFromString(prefs.getString(_prefThemeMode));
    });
  }

  Future<void> _setLocale(String code) async {
    setState(() => _localeCode = code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLocale, code);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeMode, mode.name);
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(_localeCode);

    return AppScope(
      strings: strings,
      localeCode: _localeCode,
      themeMode: _themeMode,
      setLocale: _setLocale,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        title: 'Money Tracking',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: _themeMode,
        locale: Locale(_localeCode),
        supportedLocales: const [Locale('sr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final BudgetStorage _storage = BudgetStorage();
  final BackupService _backup = BackupService();

  int _index = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<ReportsScreenState> _reportsKey =
      GlobalKey<ReportsScreenState>();

  void _select(int i) {
    setState(() => _index = i);
    if (i == 0) _dashboardKey.currentState?.reload();
    if (i == 1) _reportsKey.currentState?.reload();
  }

  Future<void> _handleExport() async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppScope.of(context).strings;
    final json = await _storage.exportJson();
    final ok = await _backup.exportToFile(json);
    if (!ok && mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.shareUnavailable)),
      );
    }
  }

  Future<void> _handleImport() async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppScope.of(context).strings;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.importConfirmTitle),
        content: Text(strings.importConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.import),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final raw = await _backup.pickBackupFile();
    if (raw == null) return;

    final ok = await _storage.importJson(raw);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? strings.importSuccess : strings.importInvalid),
    ));
    if (ok) {
      _dashboardKey.currentState?.reload();
      _reportsKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    final titles = [strings.appName, strings.navReports];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      drawer: _AppDrawer(
        selectedIndex: _index,
        onSelect: _select,
        onExport: _handleExport,
        onImport: _handleImport,
      ),
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(key: _dashboardKey, storage: _storage),
          ReportsScreen(key: _reportsKey, storage: _storage),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet),
            label: strings.navBudget,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: strings.navReports,
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onExport;
  final Future<void> Function() onImport;

  const _AppDrawer({
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
              child: Text(
                'v1.0.0',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor),
              ),
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
