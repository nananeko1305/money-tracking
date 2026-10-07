import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/strings.dart';
import '../models/fixed_cost.dart';
import '../services/fixed_cost_repository.dart';
import '../theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/fixed_cost_form_dialog.dart';
import '../widgets/fixed_cost_tile.dart';
import '../widgets/fixed_costs_total_card.dart';

/// Overview of the fixed monthly costs: the list of items with their amounts
/// and the monthly total.
class FixedCostsScreen extends StatefulWidget {
  final FixedCostRepository storage;

  const FixedCostsScreen({super.key, required this.storage});

  @override
  State<FixedCostsScreen> createState() => FixedCostsScreenState();
}

class FixedCostsScreenState extends State<FixedCostsScreen> {
  List<FixedCost> _costs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final costs = await widget.storage.fixedCosts();
    if (!mounted) return;
    setState(() {
      _costs = costs;
      _loading = false;
    });
  }

  double get _total => _costs.fold(0.0, (s, c) => s + c.amount);

  Future<void> _addCost() async {
    final result = await showFixedCostFormDialog(context);
    if (result == null) return;
    await widget.storage.addFixedCost(result.name, result.amount);
    await reload();
  }

  Future<void> _editCost(FixedCost cost) async {
    final result = await showFixedCostFormDialog(context, existing: cost);
    if (result == null) return;
    await widget.storage
        .updateFixedCost(cost.id, name: result.name, amount: result.amount);
    await reload();
  }

  Future<void> _deleteCost(FixedCost cost) async {
    final t = AppScope.of(context).strings;
    final confirmed = await showConfirmDialog(
      context,
      title: t.deleteFixedCostTitle,
      message: t.deleteFixedCostMsg(cost.name),
      confirmLabel: t.delete,
      cancelLabel: t.cancel,
      destructive: true,
    );
    if (!confirmed) return;
    await widget.storage.deleteFixedCost(cost.id);
    await reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppScope.of(context).strings;
    final pal = palette(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (_costs.isEmpty)
            _emptyHint(context, t)
          else ...[
            FixedCostsTotalCard(total: _total),
            const SizedBox(height: 16),
            ..._costs.map((cost) => FixedCostTile(
                  cost: cost,
                  onEdit: () => _editCost(cost),
                  onDelete: () => _deleteCost(cost),
                )),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCost,
            icon: const Icon(Icons.add),
            label: Text(t.addFixedCost),
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

  Widget _emptyHint(BuildContext context, AppStrings t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            t.noFixedCosts,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t.noFixedCostsSub,
            style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
