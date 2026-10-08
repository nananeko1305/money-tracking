import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist_item.dart';
import '../theme.dart';

/// One row of a checklist: a checkbox to tick it off, the name (crossed out
/// once done), the planned amount and a delete button. Tapping the row opens
/// the editor.
class ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    final faded = Theme.of(context).hintColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: pal.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
          child: Row(
            children: [
              Checkbox(
                value: item.done,
                activeColor: pal.green,
                onChanged: (v) => onToggle(v ?? false),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: item.done ? faded : null,
                    decoration: item.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (item.amount > 0)
                Text(
                  t.din(item.amount),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: item.done ? faded : pal.spent,
                  ),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 20, color: pal.danger),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
