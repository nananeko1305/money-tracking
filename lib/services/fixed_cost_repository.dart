import '../models/app_data.dart';
import '../models/fixed_cost.dart';
import 'app_data_store.dart';
import 'id_generator.dart';

/// CRUD for the user's fixed monthly costs. They live in the same persisted
/// [AppData] blob as the budget, so backups include them, but they are
/// independent of categories and untouched by the monthly rollover.
class FixedCostRepository {
  FixedCostRepository({AppDataStore? store, IdGenerator? ids})
      : _store = store ?? AppDataStore(),
        _ids = ids ?? IdGenerator();

  final AppDataStore _store;
  final IdGenerator _ids;

  FixedCost? _costById(AppData data, String id) {
    for (final c in data.fixedCosts) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<List<FixedCost>> fixedCosts() async => (await _store.read()).fixedCosts;

  Future<FixedCost> addFixedCost(String name, double amount) async {
    final data = await _store.read();
    final cost = FixedCost(id: _ids.next(), name: name, amount: amount);
    data.fixedCosts.add(cost);
    await _store.write(data);
    return cost;
  }

  Future<void> updateFixedCost(String id,
      {String? name, double? amount}) async {
    final data = await _store.read();
    final cost = _costById(data, id);
    if (cost == null) return;
    if (name != null) cost.name = name;
    if (amount != null) cost.amount = amount;
    await _store.write(data);
  }

  Future<void> deleteFixedCost(String id) async {
    final data = await _store.read();
    data.fixedCosts.removeWhere((c) => c.id == id);
    await _store.write(data);
  }
}
