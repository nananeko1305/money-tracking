import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/error_text.dart';
import '../services/auth_service.dart';
import '../services/budget_repository.dart';
import '../services/checklist_repository.dart';
import '../services/fixed_cost_repository.dart';
import '../services/live_user_data.dart';
import '../services/loan_repository.dart';
import '../services/onboarding_store.dart';
import '../services/push_service.dart';
import '../services/savings_repository.dart';
import '../services/user_session.dart';
import '../widgets/app_drawer.dart';
import '../widgets/backup_actions.dart';
import '../widgets/backup_restore_prompt.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/load_error_view.dart';
import '../widgets/local_data_prompt.dart';
import '../widgets/update_prompt.dart';
import 'checklists_screen.dart';
import 'dashboard_screen.dart';
import 'fixed_costs_screen.dart';
import 'loans_screen.dart';
import 'onboarding_screen.dart';
import 'reports_screen.dart';
import 'savings_screen.dart';

/// The signed-in app shell: bottom navigation between the dashboard, fixed
/// costs, savings, loans and reports, the drawer, and the start-up offers
/// (onboarding, filling an empty account, updates).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.session, required this.auth});

  final UserSession session;
  final AuthService auth;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  late final BudgetRepository _storage = BudgetRepository(widget.session);
  late final FixedCostRepository _fixedCosts =
      FixedCostRepository(widget.session);
  late final SavingsRepository _savings = SavingsRepository(widget.session);
  late final LoanRepository _loans = LoanRepository(widget.session);
  late final ChecklistRepository _checklists =
      ChecklistRepository(widget.session);
  final BackupActions _backup = BackupActions();
  final BackupRestorePrompt _restore = BackupRestorePrompt();
  final LocalDataPrompt _localData = LocalDataPrompt();
  final UpdatePrompt _updatePrompt = UpdatePrompt();
  final PushService _push = PushService();
  final OnboardingStore _onboarding = OnboardingStore();
  late final StreamSubscription<void> _releaseSub;
  late final StreamSubscription<Object> _writeErrorSub;

  int _index = 0;

  LiveUserData get _live => widget.session.live;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _live.addListener(_onDataChanged);
    _writeErrorSub = widget.session.writes.errors.listen(_showError);
    // A release push (received in the foreground or tapped) re-runs the
    // update check, which then offers the download.
    _releaseSub = _push.onRelease.listen((_) {
      if (mounted) _updatePrompt.offer(context);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupChecks());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _live.removeListener(_onDataChanged);
    _writeErrorSub.cancel();
    _releaseSub.cancel();
    super.dispose();
  }

  /// The month may have ended while the app was in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.session.closer.check();
  }

  /// Only the load-error view depends on this; the tabs follow the data
  /// themselves.
  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _showError(Object error) {
    if (!mounted) return;
    final strings = AppScope.of(context).strings;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorText(strings, error))));
  }

  Future<void> _runStartupChecks() async {
    if (!await _onboarding.isSeen()) {
      if (!mounted) return;
      await _showOnboarding();
      await _onboarding.markSeen();
    }
    if (!mounted) return;
    await _offerToFillEmptyAccount();
    if (!mounted) return;
    await _updatePrompt.offer(context);
    // Last, so the notification permission prompt never lands on top of the
    // onboarding or another dialog.
    await _push.start();
  }

  Future<void> _showOnboarding() {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _openChecklists() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChecklistsScreen(storage: _checklists),
    ));
  }

  /// An account the server confirms is still empty is offered the data this
  /// phone kept before accounts existed, or else a backup file. Offline the
  /// cache cannot tell an empty account from an unsynced one, so nothing is
  /// offered then.
  Future<void> _offerToFillEmptyAccount() async {
    final empty = await _live.isEmptyOnServer();
    if (empty != true || !mounted) return;
    if (await _localData.offer(context, widget.session)) return;
    if (!mounted) return;
    await _restore.offer(context, _storage);
  }

  void _select(int i) => setState(() => _index = i);

  Future<void> _signOut() async {
    final strings = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: strings.signOutTitle,
      message: strings.signOutMsg,
      confirmLabel: strings.signOut,
      cancelLabel: strings.cancel,
    );
    if (confirmed) await widget.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    final titles = [
      strings.appName,
      strings.navFixedCosts,
      strings.navSavings,
      strings.navLoans,
      strings.navReports,
    ];
    final loadError = _live.data == null ? _live.error : null;

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      drawer: AppDrawer(
        selectedIndex: _index,
        onSelect: _select,
        onExport: () => _backup.exportData(context, _storage),
        onImport: () => _backup.importData(context, _storage),
        onHowItWorks: _showOnboarding,
        onChecklists: _openChecklists,
        accountEmail: widget.session.email,
        onChangePassword: () => showChangePasswordDialog(context, widget.auth),
        onSignOut: _signOut,
      ),
      body: loadError != null
          ? LoadErrorView(message: errorText(strings, loadError))
          : IndexedStack(
              index: _index,
              children: [
                DashboardScreen(storage: _storage, savings: _savings),
                FixedCostsScreen(storage: _fixedCosts),
                SavingsScreen(storage: _savings),
                LoansScreen(storage: _loans),
                ReportsScreen(storage: _storage),
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
            icon: const Icon(Icons.receipt_long),
            label: strings.navFixedCostsShort,
          ),
          NavigationDestination(
            icon: const Icon(Icons.savings),
            label: strings.navSavings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.handshake),
            label: strings.navLoans,
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
