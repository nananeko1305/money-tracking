import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/monthly_report.dart';
import '../services/budget_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';

class ReportsScreen extends StatefulWidget {
  final BudgetRepository storage;

  const ReportsScreen({super.key, required this.storage});

  @override
  State<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  List<MonthlyReport> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Follows every change, including the ones made on another phone.
    widget.storage.changes.addListener(reload);
    reload();
  }

  @override
  void dispose() {
    widget.storage.changes.removeListener(reload);
    super.dispose();
  }

  Future<void> reload() async {
    final reports = await widget.storage.monthlyReports();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reports.isEmpty) {
      return Center(
        child: EmptyState(title: t.noReports, subtitle: t.noReportsSub),
      );
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            t.archiveSubtitle,
            style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 12),
          ..._reports.map((r) => ReportCard(report: r)),
        ],
      ),
    );
  }
}
