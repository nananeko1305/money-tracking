import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'l10n/strings.dart';
import 'screens/home_shell.dart';
import 'services/settings_store.dart';
import 'theme.dart';

/// Root widget: owns the language / theme settings and wires them into the
/// [MaterialApp] and the [AppScope] shared with the widget tree.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final SettingsStore _settings = SettingsStore();

  String _localeCode = 'sr';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final locale = await _settings.loadLocale();
    final themeMode = await _settings.loadThemeMode();
    if (!mounted) return;
    setState(() {
      _localeCode = locale;
      _themeMode = themeMode;
    });
  }

  Future<void> _setLocale(String code) async {
    setState(() => _localeCode = code);
    await _settings.saveLocale(code);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await _settings.saveThemeMode(mode);
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
