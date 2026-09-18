import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../services/backup.dart';
import '../services/budget_repository.dart';
import '../services/onboarding_store.dart';
import '../services/storage_permission.dart';
import '../services/update_checker.dart';
import '../widgets/app_drawer.dart';
import '../widgets/confirm_dialog.dart';
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';
import 'reports_screen.dart';

/// The main app shell: bottom navigation between the dashboard and reports,
/// the drawer, and the backup import / export flows.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final BudgetRepository _storage = BudgetRepository();
  final BackupService _backup = BackupService();
  final StoragePermission _permission = StoragePermission();
  final UpdateChecker _updateChecker = UpdateChecker();
  final OnboardingStore _onboarding = OnboardingStore();

  int _index = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<ReportsScreenState> _reportsKey =
      GlobalKey<ReportsScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupChecks());
  }

  Future<void> _runStartupChecks() async {
    if (!await _onboarding.isSeen()) {
      if (!mounted) return;
      await _showOnboarding();
      await _onboarding.markSeen();
    }
    if (!mounted) return;
    await _maybeOfferRestore();
    if (!mounted) return;
    await _maybeOfferUpdate();
  }

  Future<void> _showOnboarding() {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  /// Since the app is not on any store, it checks GitHub Releases and offers to
  /// download a newer version.
  Future<void> _maybeOfferUpdate() async {
    final update = await _updateChecker.checkForUpdate();
    if (!mounted || update == null) return;

    final strings = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: strings.updateAvailableTitle,
      message: strings.updateAvailableMsg(update.versionName),
      confirmLabel: strings.download,
      cancelLabel: strings.notNow,
    );
    if (!confirmed) return;

    await launchUrl(
      Uri.parse(update.downloadUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  /// On a fresh install / empty app, offers to find and import a backup saved on
  /// the device. Does nothing if the app already has data.
  Future<void> _maybeOfferRestore() async {
    final cats = await _storage.currentCategories();
    final reports = await _storage.monthlyReports();
    if (!mounted || cats.isNotEmpty || reports.isNotEmpty) return;

    final strings = AppScope.of(context).strings;
    final messenger = ScaffoldMessenger.of(context);

    // Ask before requesting the system "All files access" permission, so a
    // brand-new user isn't surprised by it.
    final wantsCheck = await showConfirmDialog(
      context,
      title: strings.restorePromptTitle,
      message: strings.restorePromptMsg,
      confirmLabel: strings.check,
      cancelLabel: strings.notNow,
    );
    if (!wantsCheck) return;

    final granted = await _permission.ensureGranted();
    if (!mounted) return;
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.storagePermissionDenied)),
      );
      return;
    }

    final backup = await _backup.findLatestBackup();
    if (!mounted) return;
    if (backup == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.noBackupsFound)),
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: strings.restoreFoundTitle,
      message: strings.restoreFoundMsg(backup.modified.toIso8601String()),
      confirmLabel: strings.import,
      cancelLabel: strings.cancel,
    );
    if (!confirmed) return;

    final raw = await _backup.readBackup(backup.path);
    if (!mounted) return;
    final ok = raw != null && await _storage.importJson(raw);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? strings.importSuccess : strings.importInvalid),
    ));
    if (ok) {
      _dashboardKey.currentState?.reload();
      _reportsKey.currentState?.reload();
    }
  }

  void _select(int i) {
    setState(() => _index = i);
    if (i == 0) _dashboardKey.currentState?.reload();
    if (i == 1) _reportsKey.currentState?.reload();
  }

  Future<void> _handleExport() async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppScope.of(context).strings;

    final granted = await _permission.ensureGranted();
    if (!mounted) return;
    if (!granted) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.storagePermissionDenied)),
      );
      return;
    }

    final json = await _storage.exportJson();
    final path = await _backup.saveToDevice(json);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(path != null ? strings.exportSaved : strings.exportFailed),
    ));
  }

  Future<void> _handleImport() async {
    final messenger = ScaffoldMessenger.of(context);
    final strings = AppScope.of(context).strings;

    final confirmed = await showConfirmDialog(
      context,
      title: strings.importConfirmTitle,
      message: strings.importConfirmMsg,
      confirmLabel: strings.import,
      cancelLabel: strings.cancel,
    );
    if (!confirmed) return;

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
      drawer: AppDrawer(
        selectedIndex: _index,
        onSelect: _select,
        onExport: _handleExport,
        onImport: _handleImport,
        onHowItWorks: _showOnboarding,
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
