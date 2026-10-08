import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';
import 'amount_row.dart';

/// The box atop a checklist: the money planned for every item, and for the
/// ones not ticked off yet.
class ChecklistTotalCard extends StatelessWidget {
  final double total;
  final double left;

  const ChecklistTotalCard({
    super.key,
    required this.total,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.subtleFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: Column(
        children: [
          AmountRow(t.checklistTotal, t.din(total), emphasized: true),
          const SizedBox(height: 8),
          AmountRow(t.remaining, t.din(left), color: pal.spent),
        ],
      ),
    );
  }
}
