import 'package:flutter/foundation.dart' show Listenable;

import '../models/savings_fund.dart';
import '../models/transaction.dart';
import 'app_data_encoder.dart';
import 'batch_commits.dart';
import 'category_palette.dart';
import 'id_generator.dart';
import 'user_collections.dart';
import 'user_session.dart';

/// CRUD for the signed-in account's savings funds and their deposits /
/// withdrawals. Closing a month never touches them. Writes are not awaited
/// (see [WriteErrors]).
class SavingsRepository {
  SavingsRepository(
    this._session, {
    IdGenerator? ids,
    CategoryPalette? palette,
    this._encoder = const AppDataEncoder(),
  })  : _ids = ids ?? IdGenerator(),
        _palette = palette ?? CategoryPalette();

  final UserSession _session;
  final IdGenerator _ids;
  final CategoryPalette _palette;
  final AppDataEncoder _encoder;

  UserCollections get _docs => _session.docs;

  void _write(Future<void> write) => _session.writes.track(write);

  /// Notifies whenever the account's data changes, on this phone or another.
  Listenable get changes => _session.live;

  Future<List<SavingsFund>> funds() async =>
      (await _session.live.ready()).savingsFunds;

  /// Net amount moved into all funds during the calendar month of [month].
  Future<double> netSavedInMonth(DateTime month) async =>
      (await funds()).fold<double>(0.0, (s, f) => s + f.netInMonth(month));

  Future<SavingsFund> addFund(
    String name, {
    double target = 0,
    double openingBalance = 0,
  }) async {
    final fund = SavingsFund(
      id: _ids.next(),
      name: name,
      color: _palette.randomColor(),
      createdAt: DateTime.now().toIso8601String(),
      target: target,
      openingBalance: openingBalance,
    );
    _write(_docs.savingsFunds.doc(fund.id).set(_encoder.savingsFund(fund)));
    return fund;
  }

  Future<void> updateFund(
    String id, {
    String? name,
    double? target,
    double? openingBalance,
  }) async {
    _write(_docs.savingsFunds.doc(id).update({
      'name': ?name,
      'target': ?target,
      'openingBalance': ?openingBalance,
    }));
  }

  /// Deletes the fund together with its entries.
  Future<void> deleteFund(String id) async {
    final entries = _session.live.documents[UserCollections.savingsEntriesName];
    commitInBatches(_docs, _session.writes, [
      (b) => b.delete(_docs.savingsFunds.doc(id)),
      for (final doc in entries)
        if (doc['fundId'] == id)
          (b) => b.delete(_docs.savingsEntries.doc(doc['id'] as String)),
    ]);
  }

  Future<void> deposit(String fundId, double amount, String description) =>
      _addEntry(fundId, amount, description);

  Future<void> withdraw(String fundId, double amount, String description) =>
      _addEntry(fundId, -amount, description);

  Future<void> deleteEntry(String fundId, String entryId) async =>
      _write(_docs.savingsEntries.doc(entryId).delete());

  /// Records a signed entry: positive for a deposit, negative for a withdrawal.
  Future<void> _addEntry(
      String fundId, double signedAmount, String description) async {
    final entry = Transaction(
      id: _ids.next(),
      amount: signedAmount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    );
    _write(_docs.savingsEntries
        .doc(entry.id)
        .set(_encoder.savingsEntry(entry, fundId: fundId)));
  }
}
