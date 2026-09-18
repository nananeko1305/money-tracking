import 'dart:convert';

import '../models/app_data.dart';
import '../models/category.dart';
import '../models/monthly_report.dart';
import '../models/transaction.dart';
import 'app_data_store.dart';
import 'category_palette.dart';
import 'id_generator.dart';
import 'monthly_rollover.dart';

/// Application-facing budget operations. Coordinates persistence
/// ([AppDataStore]), the monthly reset rule ([MonthlyRollover]) and id / color
/// generation, exposing category and transaction CRUD plus backup
/// import / export. Every read first applies the monthly rollover.
class BudgetRepository {
  BudgetRepository({
    AppDataStore? store,
    MonthlyRollover? rollover,
    IdGenerator? ids,
    CategoryPalette? palette,
  })  : _store = store ?? AppDataStore(),
        _rollover = rollover ?? const MonthlyRollover(),
        _ids = ids ?? IdGenerator(),
        _palette = palette ?? CategoryPalette();

  final AppDataStore _store;
  final MonthlyRollover _rollover;
  final IdGenerator _ids;
  final CategoryPalette _palette;

  /// Reads state, first applying the monthly rollover and persisting it if it
  /// ran.
  Future<AppData> _load() async {
    final data = await _store.read();
    if (_rollover.apply(data)) {
      await _store.write(data);
    }
    return data;
  }

  Category? _categoryById(AppData data, String id) {
    for (final c in data.currentCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<List<Category>> currentCategories() async =>
      (await _load()).currentCategories;

  Future<List<MonthlyReport>> monthlyReports() async =>
      (await _load()).monthlyReports;

  Future<Category> addCategory(String name, double budget) async {
    final data = await _load();
    final category = Category(
      id: _ids.next(),
      name: name,
      budget: budget,
      color: _palette.randomColor(),
      createdAt: DateTime.now().toIso8601String(),
    );
    data.currentCategories.add(category);
    await _store.write(data);
    return category;
  }

  Future<void> updateCategory(String id,
      {String? name, double? budget}) async {
    final data = await _load();
    final category = _categoryById(data, id);
    if (category == null) return;
    if (name != null) category.name = name;
    if (budget != null) category.budget = budget;
    await _store.write(data);
  }

  Future<void> deleteCategory(String id) async {
    final data = await _load();
    data.currentCategories.removeWhere((c) => c.id == id);
    await _store.write(data);
  }

  Future<void> addExpense(
      String categoryId, double amount, String description) async {
    final data = await _load();
    final category = _categoryById(data, categoryId);
    if (category == null) return;
    category.transactions.add(Transaction(
      id: _ids.next(),
      amount: amount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    ));
    await _store.write(data);
  }

  Future<void> deleteTransaction(
      String categoryId, String transactionId) async {
    final data = await _load();
    final category = _categoryById(data, categoryId);
    if (category == null) return;
    category.transactions.removeWhere((t) => t.id == transactionId);
    await _store.write(data);
  }

  /// Days remaining until the first of next month.
  int daysUntilReset() => _rollover.daysUntilReset();

  /// Serialises the whole store for backup.
  Future<String> exportJson() async {
    final data = await _load();
    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }

  /// Replaces the whole store from a backup string. Returns true on success.
  Future<bool> importJson(String raw) async {
    try {
      final data = AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      await _store.write(data);
      return true;
    } catch (_) {
      return false;
    }
  }
}
