import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/checklist.dart';
import '../services/checklist_repository.dart';
import '../theme.dart';
import '../widgets/checklist_card.dart';
import '../widgets/checklist_name_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import 'checklist_screen.dart';

/// The checklists, opened from the drawer: every list with its progress and
/// totals, and a button to start a new one.
class ChecklistsScreen extends StatefulWidget {
  final ChecklistRepository storage;

  const ChecklistsScreen({super.key, required this.storage});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  List<Checklist> _lists = [];
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
      _lists = lists;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final name = await showChecklistNameDialog(context);
    if (name != null) await widget.storage.addChecklist(name);
  }

  Future<void> _rename(Checklist list) async {
    final name = await showChecklistNameDialog(context, existing: list);
    if (name != null) await widget.storage.renameChecklist(list.id, name);
  }

  Future<void> _delete(Checklist list) async {
    final t = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: t.deleteChecklistTitle,
      message: t.deleteChecklistMsg(list.name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      destructive: true,
    );
    if (confirmed) await widget.storage.deleteChecklist(list.id);
  }

  void _open(Checklist list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChecklistScreen(storage: widget.storage, checklistId: list.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.navChecklists)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                if (_lists.isEmpty)
                  EmptyState(title: t.noChecklists, subtitle: t.noChecklistsSub),
                ..._lists.map((list) => ChecklistCard(
                      checklist: list,
                      onTap: () => _open(list),
                      onRename: () => _rename(list),
                      onDelete: () => _delete(list),
                    )),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: Text(t.addChecklist),
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
            ),
    );
  }
}
