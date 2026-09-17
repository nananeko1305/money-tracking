import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget.dart';

/// Persists and mutates the budget app state using [SharedPreferences].
///
/// Mirrors the behaviour of the original Expo storage layer: data lives under a
/// single JSON key, and every read first performs the monthly rollover check.
class BudgetStorage {
  static const String _storageKey = 'budget_app_data';

  static const List<String> _palette = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8',
    '#F7DC6F', '#BB8FCE', '#85C1E2', '#F8B739', '#52B788',
    '#E07A5F', '#81B29A', '#F2CC8F', '#A8DADC', '#E63946',
  ];

  final Random _random = Random();

  String randomColor() => _palette[_random.nextInt(_palette.length)];

  String _newId() =>
      '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(100000)}';

  static String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  Future<AppData> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      final data = AppData.empty();
      await _write(data);
      return data;
    }
    try {
      return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppData.empty();
    }
  }

  Future<void> _write(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }

  /// Loads data, archiving the previous month and clearing transactions when a
  /// new month has begun.
  Future<AppData> loadAndReset() async {
    final data = await _read();
    final lastReset = DateTime.tryParse(data.lastResetDate) ?? DateTime.now();
    final lastResetMonth = _monthKey(lastReset);
    final currentMonth = _monthKey(DateTime.now());

    if (lastResetMonth != currentMonth && data.currentCategories.isNotEmpty) {
      final totalBudget =
          data.currentCategories.fold(0.0, (s, c) => s + c.budget);
      final totalSpent =
          data.currentCategories.fold(0.0, (s, c) => s + c.spent);

      final report = MonthlyReport(
        id: lastResetMonth,
        month: lastResetMonth,
        categories: data.currentCategories.map((c) => c.copy()).toList(),
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        totalRemaining: totalBudget - totalSpent,
        savedAt: DateTime.now().toIso8601String(),
      );

      // Keep category structure, clear the recorded transactions.
      for (final c in data.currentCategories) {
        c.transactions = [];
      }

      data.monthlyReports = [report, ...data.monthlyReports].take(12).toList();
      data.lastResetDate = DateTime.now().toIso8601String();
      await _write(data);
    }

    return data;
  }

  Future<List<Category>> currentCategories() async =>
      (await loadAndReset()).currentCategories;

  Future<List<MonthlyReport>> monthlyReports() async =>
      (await loadAndReset()).monthlyReports;

  Future<Category> addCategory(String name, double budget) async {
    final data = await loadAndReset();
    final category = Category(
      id: _newId(),
      name: name,
      budget: budget,
      color: randomColor(),
      createdAt: DateTime.now().toIso8601String(),
    );
    data.currentCategories.add(category);
    await _write(data);
    return category;
  }

  Future<void> updateCategory(String id,
      {String? name, double? budget}) async {
    final data = await loadAndReset();
    final category =
        data.currentCategories.where((c) => c.id == id).firstOrNull;
    if (category == null) return;
    if (name != null) category.name = name;
    if (budget != null) category.budget = budget;
    await _write(data);
  }

  Future<void> deleteCategory(String id) async {
    final data = await loadAndReset();
    data.currentCategories.removeWhere((c) => c.id == id);
    await _write(data);
  }

  Future<void> addExpense(
      String categoryId, double amount, String description) async {
    final data = await loadAndReset();
    final category =
        data.currentCategories.where((c) => c.id == categoryId).firstOrNull;
    if (category == null) return;
    category.transactions.add(Transaction(
      id: _newId(),
      amount: amount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    ));
    await _write(data);
  }

  Future<void> deleteTransaction(
      String categoryId, String transactionId) async {
    final data = await loadAndReset();
    final category =
        data.currentCategories.where((c) => c.id == categoryId).firstOrNull;
    if (category == null) return;
    category.transactions.removeWhere((t) => t.id == transactionId);
    await _write(data);
  }

  /// Days remaining until the first of next month.
  int daysUntilReset() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return nextMonth.difference(now).inHours ~/ 24 + 1;
  }

  /// Serialises the whole store for backup.
  Future<String> exportJson() async {
    final data = await loadAndReset();
    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }

  /// Replaces the whole store from a backup string. Returns true on success.
  Future<bool> importJson(String raw) async {
    try {
      final data = AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      await _write(data);
      return true;
    } catch (_) {
      return false;
    }
  }
}
