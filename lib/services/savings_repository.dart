import 'package:flutter/foundation.dart' show Listenable;

import '../models/money_currency.dart';
import '../models/savings_fund.dart';
import '../models/savings_totals.dart';
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

  SavingsFund? _fundById(String id) =>
      _session.live.data?.savingsFunds.where((f) => f.id == id).firstOrNull;

  Future<List<SavingsFund>> funds() async =>
      (await _session.live.ready()).savingsFunds;

  /// Net amount moved into the funds during the calendar month of [month],
  /// per currency (of each deposit or withdrawal): what comes out of that
  /// currency's monthly income.
  Future<Map<MoneyCurrency, double>> netSavedInMonth(DateTime month) async => {
        for (final t in SavingsTotals.of(await funds(), month))
          t.currency: t.thisMonth,
      };

  Future<SavingsFund> addFund(
    String name, {
    double target = 0,
    Map<MoneyCurrency, double> openingBalances = const {},
    MoneyCurrency currency = MoneyCurrency.rsd,
  }) async {
    final fund = SavingsFund(
      id: _ids.next(),
      name: name,
      color: _palette.randomColor(),
      createdAt: DateTime.now().toIso8601String(),
      target: target,
      openingBalances: {...openingBalances},
      currency: currency,
    );
    _write(_docs.savingsFunds.doc(fund.id).set(_encoder.savingsFund(fund)));
    return fund;
  }

  Future<void> updateFund(
    String id, {
    String? name,
    double? target,
    Map<MoneyCurrency, double>? openingBalances,
    MoneyCurrency? currency,
  }) async {
    final current = _fundById(id);
    final balances = openingBalances ?? current?.openingBalances ?? const {};
    final main = currency ?? current?.currency ?? MoneyCurrency.rsd;
    _write(_docs.savingsFunds.doc(id).update({
      'name': ?name,
      'target': ?target,
      if (currency != null) 'currency': currency.name,
      if (openingBalances != null || currency != null)
        ...SavingsFund.openingFields(balances, main),
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

  /// [currency] defaults to the fund's own.
  Future<void> deposit(String fundId, double amount, String description,
          {MoneyCurrency? currency}) =>
      _addEntry(fundId, amount, description, currency);

  Future<void> withdraw(String fundId, double amount, String description,
          {MoneyCurrency? currency}) =>
      _addEntry(fundId, -amount, description, currency);

  Future<void> deleteEntry(String fundId, String entryId) async =>
      _write(_docs.savingsEntries.doc(entryId).delete());

  /// Records a signed entry: positive for a deposit, negative for a withdrawal.
  Future<void> _addEntry(String fundId, double signedAmount,
      String description, MoneyCurrency? currency) async {
    final entry = Transaction(
      id: _ids.next(),
      amount: signedAmount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
      currency: currency ?? _fundById(fundId)?.currency,
    );
    _write(_docs.savingsEntries
        .doc(entry.id)
        .set(_encoder.savingsEntry(entry, fundId: fundId)));
  }
}
