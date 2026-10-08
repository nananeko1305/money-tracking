import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../services/checklist_repository.dart';
import '../theme.dart';
import '../widgets/checklist_item_dialog.dart';
import '../widgets/checklist_item_tile.dart';
import '../widgets/checklist_total_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

/// One checklist: the planned total and what is left on top, then the items
/// to tick off, edit or remove, and a button to add more.
class ChecklistScreen extends StatefulWidget {
  final ChecklistRepository storage;
  final String checklistId;

  const ChecklistScreen({
    super.key,
    required this.storage,
    required this.checklistId,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  Checklist? _list;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Follows every change, including the ones made on another phone.
    widget.storage.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.storage.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final lists = await widget.storage.checklists();
    if (!mounted) return;
    setState(() {
      _list = lists.where((l) => l.id == widget.checklistId).firstOrNull;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    final result = await showChecklistItemDialog(context);
    if (result == null) return;
    await widget.storage
        .addItem(widget.checklistId, result.name, result.amount);
  }

  Future<void> _editItem(ChecklistItem item) async {
    final result = await showChecklistItemDialog(context, existing: item);
    if (result == null) return;
    await widget.storage
        .updateItem(item.id, name: result.name, amount: result.amount);
  }

  Future<void> _deleteItem(ChecklistItem item) async {
    final t = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: t.deleteItemTitle,
      message: t.deleteItemMsg(item.name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      destructive: true,
    );
    if (confirmed) await widget.storage.deleteItem(item.id);
  }

  /// Ticks the box at once; the live data catches up a moment later.
  Future<void> _toggle(ChecklistItem item, bool done) async {
    setState(() => item.done = done);
    await widget.storage.setItemDone(item.id, done);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final list = _list;

    return Scaffold(
      appBar: AppBar(title: Text(list?.name ?? t.navChecklists)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : list == null
              ? Center(child: Text(t.checklistNotFound))
              : _buildBody(context, list),
    );
  }

  Widget _buildBody(BuildContext context, Checklist list) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        ChecklistTotalCard(total: list.total, left: list.left),
        const SizedBox(height: 16),
        if (list.items.isEmpty)
          EmptyState(title: t.noItems, subtitle: t.noItemsSub),
        ...list.items.map((item) => ChecklistItemTile(
              item: item,
              onToggle: (done) => _toggle(item, done),
              onEdit: () => _editItem(item),
              onDelete: () => _deleteItem(item),
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: Text(t.addItem),
          style: OutlinedButton.styleFrom(
            foregroundColor: pal.green,
            side: BorderSide(color: pal.green, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
