import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme.dart';

/// The summary card atop the fixed costs list: the sum of all fixed costs for
/// one month.
class FixedCostsTotalCard extends StatelessWidget {
  final double total;

  const FixedCostsTotalCard({super.key, required this.total});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t.fixedCostsTotal,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            t.din(total),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: pal.spent,
            ),
          ),
        ],
      ),
    );
  }
}
