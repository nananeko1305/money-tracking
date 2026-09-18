import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../services/backup.dart';
import '../services/budget_repository.dart';
import '../widgets/app_drawer.dart';
import '../widgets/confirm_dialog.dart';
import 'dashboard_screen.dart';
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
