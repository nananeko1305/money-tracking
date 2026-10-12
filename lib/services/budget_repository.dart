import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:flutter/foundation.dart' show Listenable;

import '../models/app_data.dart';
import '../models/category.dart';
import '../models/money_currency.dart';
import '../models/monthly_report.dart';
import '../models/transaction.dart';
import 'app_data_encoder.dart';
import 'batch_commits.dart';
import 'category_palette.dart';
import 'id_generator.dart';
import 'monthly_rollover.dart';
import 'user_collections.dart';
import 'user_session.dart';

/// Application-facing budget operations on the signed-in account: the monthly
/// income, categories and their expenses, and reports.
/// Reads come from the live view; every change goes straight to its own
/// document and is not awaited (see [WriteErrors]). Closing the month is the
/// [MonthCloser]'s job.
class BudgetRepository {
  BudgetRepository(
    this._session, {
    IdGenerator? ids,
    CategoryPalette? palette,
    this._encoder = const AppDataEncoder(),
    this._rollover = const MonthlyRollover(),
  })  : _ids = ids ?? IdGenerator(),
        _palette = palette ?? CategoryPalette();

  final UserSession _session;
  final IdGenerator _ids;
  final CategoryPalette _palette;
  final AppDataEncoder _encoder;
  final MonthlyRollover _rollover;

  UserCollections get _docs => _session.docs;

  Future<AppData> _data() => _session.live.ready();

  void _write(Future<void> write) => _session.writes.track(write);

  /// Notifies whenever the account's data changes, on this phone or another.
  Listenable get changes => _session.live;

  Future<List<Category>> currentCategories() async =>
      (await _data()).currentCategories;

  Future<List<MonthlyReport>> monthlyReports() async =>
      (await _data()).monthlyReports;

  /// True when the account holds no data at all.
  Future<bool> isEmpty() async => (await _data()).isEmpty;

  /// The money available for the month in each currency: salary plus any
  /// other income. 0 means it has not been set.
  Future<Map<MoneyCurrency, double>> monthlyIncomes() async {
    final data = await _data();
    return {for (final c in MoneyCurrency.values) c: data.incomeIn(c)};
  }

  /// Sets the monthly income in dinars and in euros; 0 clears one. The
  /// values carry over to the next months until they are changed.
  Future<void> setMonthlyIncome({required double rsd, required double eur}) async =>
      _write(_docs.profile.set(
        {'monthlyIncome': rsd, 'monthlyIncomeEur': eur},
        SetOptions(merge: true),
      ));

  Future<Category> addCategory(
    String name,
    double budget, {
    MoneyCurrency currency = MoneyCurrency.rsd,
  }) async {
    final category = Category(
      id: _ids.next(),
      name: name,
      budget: budget,
      currency: currency,
      color: _palette.randomColor(),
      createdAt: DateTime.now().toIso8601String(),
    );
    _write(_docs.categories.doc(category.id).set(_encoder.category(category)));
    return category;
  }

  /// Changing the currency moves the category's expenses with it.
  Future<void> updateCategory(String id,
      {String? name, double? budget, MoneyCurrency? currency}) async {
    _write(_docs.categories.doc(id).update({
      'name': ?name,
      'budget': ?budget,
      if (currency != null) 'currency': currency.name,
    }));
  }

  /// Deletes the category together with its expenses.
  Future<void> deleteCategory(String id) async {
    final expenses = _session.live.documents[UserCollections.expensesName];
    commitInBatches(_docs, _session.writes, [
      (b) => b.delete(_docs.categories.doc(id)),
      for (final doc in expenses)
        if (doc['categoryId'] == id)
          (b) => b.delete(_docs.expenses.doc(doc['id'] as String)),
    ]);
  }

  Future<void> addExpense(
      String categoryId, double amount, String description) async {
    final expense = Transaction(
      id: _ids.next(),
      amount: amount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    );
    _write(_docs.expenses.doc(expense.id).set(_encoder.expense(
          expense,
          categoryId: categoryId,
          month: _session.live.openMonth,
        )));
  }

  Future<void> deleteTransaction(
      String categoryId, String transactionId) async {
    _write(_docs.expenses.doc(transactionId).delete());
  }

  /// Days remaining until the first of next month.
  int daysUntilReset() => _rollover.daysUntilReset();
}
