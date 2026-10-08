import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../theme.dart';
import 'amount_row.dart';

/// One checklist in the overview: its name, how many items are done, the
/// planned total and what is left, with rename / delete actions. Tapping it
/// opens the list.
class ChecklistCard extends StatelessWidget {
  final Checklist checklist;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const ChecklistCard({
    super.key,
    required this.checklist,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final list = checklist;
    final count = list.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    t.itemsDone(list.doneCount, count),
                    style: TextStyle(
                        fontSize: 13, color: Theme.of(context).hintColor),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onRename,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close, size: 20, color: pal.danger),
                    onPressed: onDelete,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    AmountRow(t.checklistTotal, t.din(list.total)),
                    const SizedBox(height: 4),
                    AmountRow(t.remaining, t.din(list.left),
                        color: pal.spent),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: count == 0 ? 0 : list.doneCount / count,
                        minHeight: 8,
                        backgroundColor: pal.subtleFill,
                        valueColor: AlwaysStoppedAnimation(pal.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
