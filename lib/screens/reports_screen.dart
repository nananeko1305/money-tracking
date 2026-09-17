import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../models/budget.dart';
import '../services/storage.dart';
import '../theme.dart';

class ReportsScreen extends StatefulWidget {
  final BudgetStorage storage;

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
    reload();
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
      return _EmptyState(t: t);
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
          ..._reports.map((r) => _ReportCard(report: r, t: t)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppStrings t;
  const _EmptyState({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.noReports,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.noReportsSub,
              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final MonthlyReport report;
  final AppStrings t;
  const _ReportCard({required this.report, required this.t});

  @override
  Widget build(BuildContext context) {
    final pal = palette(context);
    final percent = report.totalBudget > 0
        ? (report.totalSpent / report.totalBudget) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.monthYear(report.month),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            t.savedOn(report.savedAt),
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
          ),
          const Divider(height: 24),
          _row(t.totalBudget, t.din(report.totalBudget), null, false),
          const SizedBox(height: 8),
          _row(t.totalSpent, t.din(report.totalSpent), pal.spent, false),
          const SizedBox(height: 8),
          _row(
            t.remainingAtEnd,
            t.din(report.totalRemaining),
            report.totalRemaining >= 0 ? pal.positive : pal.danger,
            true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: pal.subtleFill,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              t.spentPercent(percent.toStringAsFixed(1)),
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.byCategory,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          ...report.categories.map((c) => _categoryRow(context, c, pal)),
        ],
      ),
    );
  }

  Widget _categoryRow(BuildContext context, Category category, AppPalette pal) {
    final percent = category.percentageSpent;
    final positive = category.remaining >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: hexColor(category.color), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(category.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${t.amount(category.spent)} / ${t.din(category.budget)}',
                  style: TextStyle(
                      fontSize: 13, color: Theme.of(context).hintColor),
                ),
                Text(
                  '(${percent.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: positive ? pal.positive : pal.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color? color, bool bold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: color)),
      ],
    );
  }
}
