import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:flutter/foundation.dart' show Listenable;

import '../models/app_data.dart';
import '../models/category.dart';
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
/// income, categories and their expenses, reports, and backup import / export.
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

  /// The money available for the month: salary plus any other income. 0 means
  /// it has not been set.
  Future<double> monthlyIncome() async => (await _data()).monthlyIncome;

  /// Sets the monthly income; 0 clears it. The value carries over to the next
  /// months until it is changed.
  Future<void> setMonthlyIncome(double income) async => _write(_docs.profile
      .set({'monthlyIncome': income}, SetOptions(merge: true)));

  Future<Category> addCategory(String name, double budget) async {
    final category = Category(
      id: _ids.next(),
      name: name,
      budget: budget,
      color: _palette.randomColor(),
      createdAt: DateTime.now().toIso8601String(),
    );
    _write(_docs.categories.doc(category.id).set(_encoder.category(category)));
    return category;
  }

  Future<void> updateCategory(String id,
      {String? name, double? budget}) async {
    _write(_docs.categories.doc(id).update({
      'name': ?name,
      'budget': ?budget,
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

  /// Serialises the account's data for backup, in the same format the app
  /// has always exported.
  Future<String> exportJson() async =>
      const JsonEncoder.withIndent('  ').convert((await _data()).toJson());

  /// Replaces the account's data with a backup. Returns false when [raw] is
  /// not a valid backup.
  Future<bool> importJson(String raw) async {
    final AppData data;
    try {
      data = AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return false;
    }
    await _data();
    _session.replacer.replaceWith(data);
    return true;
  }
}
