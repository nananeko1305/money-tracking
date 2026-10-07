import '../models/app_data.dart';
import '../models/savings_fund.dart';
import '../models/transaction.dart';
import 'app_data_store.dart';
import 'category_palette.dart';
import 'id_generator.dart';

/// CRUD for savings funds and their deposits / withdrawals. Funds live in the
/// same persisted [AppData] blob as the budget, so backups include them, but
/// the monthly rollover never clears them.
class SavingsRepository {
  SavingsRepository({
    AppDataStore? store,
    IdGenerator? ids,
    CategoryPalette? palette,
  })  : _store = store ?? AppDataStore(),
        _ids = ids ?? IdGenerator(),
        _palette = palette ?? CategoryPalette();

  final AppDataStore _store;
  final IdGenerator _ids;
  final CategoryPalette _palette;

  SavingsFund? _fundById(AppData data, String id) {
    for (final f in data.savingsFunds) {
      if (f.id == id) return f;
    }
    return null;
  }

  Future<List<SavingsFund>> funds() async =>
      (await _store.read()).savingsFunds;

  /// Net amount moved into all funds during the calendar month of [month].
  Future<double> netSavedInMonth(DateTime month) async =>
      (await funds()).fold<double>(0.0, (s, f) => s + f.netInMonth(month));

  Future<SavingsFund> addFund(
    String name, {
    double target = 0,
    double openingBalance = 0,
  }) async {
    final data = await _store.read();
    final fund = SavingsFund(
      id: _ids.next(),
      name: name,
      color: _palette.randomColor(),
      createdAt: DateTime.now().toIso8601String(),
      target: target,
      openingBalance: openingBalance,
    );
    data.savingsFunds.add(fund);
    await _store.write(data);
    return fund;
  }

  Future<void> updateFund(
    String id, {
    String? name,
    double? target,
    double? openingBalance,
  }) async {
    final data = await _store.read();
    final fund = _fundById(data, id);
    if (fund == null) return;
    if (name != null) fund.name = name;
    if (target != null) fund.target = target;
    if (openingBalance != null) fund.openingBalance = openingBalance;
    await _store.write(data);
  }

  Future<void> deleteFund(String id) async {
    final data = await _store.read();
    data.savingsFunds.removeWhere((f) => f.id == id);
    await _store.write(data);
  }

  Future<void> deposit(String fundId, double amount, String description) =>
      _addEntry(fundId, amount, description);

  Future<void> withdraw(String fundId, double amount, String description) =>
      _addEntry(fundId, -amount, description);

  Future<void> deleteEntry(String fundId, String entryId) async {
    final data = await _store.read();
    final fund = _fundById(data, fundId);
    if (fund == null) return;
    fund.entries.removeWhere((e) => e.id == entryId);
    await _store.write(data);
  }

  /// Records a signed entry: positive for a deposit, negative for a withdrawal.
  Future<void> _addEntry(
      String fundId, double signedAmount, String description) async {
    final data = await _store.read();
    final fund = _fundById(data, fundId);
    if (fund == null) return;
    fund.entries.add(Transaction(
      id: _ids.next(),
      amount: signedAmount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    ));
    await _store.write(data);
  }
}
