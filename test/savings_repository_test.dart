import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/money_currency.dart';
import 'package:budget_tracker/models/savings_fund.dart';
import 'package:budget_tracker/models/savings_totals.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/savings_repository.dart';

import 'fake_account.dart';

void main() {
  Future<SavingsRepository> openRepo() async =>
      SavingsRepository(await openFakeSession());

  test('balance is opening balance plus deposits minus withdrawals', () async {
    final repo = await openRepo();
    final fund = await repo.addFund('Hitni fond',
        target: 200000, openingBalances: {MoneyCurrency.rsd: 50000});

    await repo.deposit(fund.id, 20000, 'plata');
    await repo.withdraw(fund.id, 5000, '');

    await settle();
    final saved = (await repo.funds()).single;
    expect(saved.balanceIn(MoneyCurrency.rsd), 65000);
    expect(saved.entries.map((e) => e.amount), [20000, -5000]);
    expect(saved.percentOfTarget, closeTo(32.5, 1e-9));
  });

  test('this month counts entries only, never the opening balance', () async {
    final repo = await openRepo();
    final fund = await repo.addFund('Letovanje',
        openingBalances: {MoneyCurrency.rsd: 500000});
    await repo.deposit(fund.id, 10000, '');
    await repo.withdraw(fund.id, 3000, '');

    await settle();
    expect(await repo.netSavedInMonth(DateTime.now()), {MoneyCurrency.rsd: 7000});
  });

  test('netInMonth ignores entries from other months', () {
    final fund = SavingsFund(
      id: 'f',
      name: 'F',
      color: '#000000',
      createdAt: '2026-09-01T00:00:00.000',
      entries: [
        const Transaction(
            id: 'a', amount: 1000, description: '', date: '2026-09-15T10:00:00.000'),
        const Transaction(
            id: 'b', amount: 2000, description: '', date: '2026-10-02T10:00:00.000'),
      ],
    );
    expect(fund.netInMonth(DateTime(2026, 9, 30), MoneyCurrency.rsd), 1000);
    expect(fund.netInMonth(DateTime(2026, 10, 1), MoneyCurrency.rsd), 2000);
  });

  test('update, delete entry and delete fund', () async {
    final repo = await openRepo();
    final fund = await repo.addFund('Auto');
    await repo.deposit(fund.id, 1000, '');
    await repo.updateFund(fund.id,
        name: 'Novi auto',
        target: 900000,
        openingBalances: {MoneyCurrency.rsd: 100});

    await settle();
    var saved = (await repo.funds()).single;
    expect(saved.name, 'Novi auto');
    expect(saved.target, 900000);
    expect(saved.balanceIn(MoneyCurrency.rsd), 1100);

    await repo.deleteEntry(fund.id, saved.entries.single.id);
    await settle();
    saved = (await repo.funds()).single;
    expect(saved.balanceIn(MoneyCurrency.rsd), 100);

    await repo.deleteFund(fund.id);
    await settle();
    expect(await repo.funds(), isEmpty);
  });

  test('a euro fund keeps its currency and its own monthly sum',
      () async {
    final repo = await openRepo();
    final dinars = await repo.addFund('Hitni fond');
    final euros = await repo.addFund('Devize',
        openingBalances: {MoneyCurrency.eur: 1000}, currency: MoneyCurrency.eur);
    await settle(); // as on screen: a fund is deposited into once it shows
    await repo.deposit(dinars.id, 5000, '');
    await repo.deposit(euros.id, 100, '');
    await settle();

    final saved = (await repo.funds()).firstWhere((f) => f.id == euros.id);
    expect(saved.currency, MoneyCurrency.eur);
    expect(saved.balanceIn(MoneyCurrency.eur), 1100);
    expect(saved.entries.single.currency, MoneyCurrency.eur);
    // Each currency is summed on its own.
    expect(await repo.netSavedInMonth(DateTime.now()),
        {MoneyCurrency.rsd: 5000, MoneyCurrency.eur: 100});

    // Changing the goal's currency never converts the money already saved.
    await repo.updateFund(euros.id, currency: MoneyCurrency.rsd);
    await settle();
    final changed = (await repo.funds()).firstWhere((f) => f.id == euros.id);
    expect(changed.currency, MoneyCurrency.rsd);
    expect(changed.openingBalances, {MoneyCurrency.eur: 1000});
    expect(changed.balanceIn(MoneyCurrency.eur), 1100);
    expect(await repo.netSavedInMonth(DateTime.now()),
        {MoneyCurrency.rsd: 5000, MoneyCurrency.eur: 100});
  });

  test('one fund holds dinars and euros side by side', () async {
    final repo = await openRepo();
    final fund = await repo.addFund('Hitni fond',
        target: 100000,
        openingBalances: {MoneyCurrency.rsd: 40000, MoneyCurrency.eur: 500});
    await settle();
    await repo.deposit(fund.id, 10000, ''); // the fund's own currency
    await repo.deposit(fund.id, 200, '', currency: MoneyCurrency.eur);
    await repo.withdraw(fund.id, 50, '', currency: MoneyCurrency.eur);
    await settle();

    final saved = (await repo.funds()).single;
    expect(saved.currencies, [MoneyCurrency.rsd, MoneyCurrency.eur]);
    expect(saved.balanceIn(MoneyCurrency.rsd), 50000);
    expect(saved.balanceIn(MoneyCurrency.eur), 650);
    expect(saved.entries.map((e) => e.currency),
        [MoneyCurrency.rsd, MoneyCurrency.eur, MoneyCurrency.eur]);
    // The goal counts only its own currency.
    expect(saved.percentOfTarget, closeTo(50, 1e-9));
    expect(await repo.netSavedInMonth(DateTime.now()),
        {MoneyCurrency.rsd: 10000, MoneyCurrency.eur: 150});

    final totals = SavingsTotals.of([saved], DateTime.now());
    expect(totals.map((t) => (t.currency, t.balance, t.thisMonth)), [
      (MoneyCurrency.rsd, 50000, 10000),
      (MoneyCurrency.eur, 650, 150),
    ]);

    // Editing the opening balances replaces them; the entries stay.
    await repo.updateFund(fund.id, openingBalances: {MoneyCurrency.eur: 100});
    await settle();
    final edited = (await repo.funds()).single;
    expect(edited.openingBalances, {MoneyCurrency.eur: 100});
    expect(edited.balanceIn(MoneyCurrency.rsd), 10000);
    expect(edited.balanceIn(MoneyCurrency.eur), 250);
  });

  test('a fund stores every opening balance and the old single one',
      () async {
    final firestore = FakeFirebaseFirestore();
    final repo = SavingsRepository(await openFakeSession(firestore: firestore));
    final fund = await repo.addFund('Hitni fond',
        openingBalances: {MoneyCurrency.rsd: 40000, MoneyCurrency.eur: 500});
    await settle();

    final doc = await firestore
        .collection('users')
        .doc(testUid)
        .collection('savingsFunds')
        .doc(fund.id)
        .get();
    expect(doc.data()!['openingBalances'], {'rsd': 40000, 'eur': 500});
    // App versions from before funds held several currencies read this one.
    expect(doc.data()!['openingBalance'], 40000);
  });

  test('an empty fund shows its own currency', () {
    final fund = SavingsFund(
      id: 'f',
      name: 'F',
      color: '#000000',
      createdAt: '2026-09-01T00:00:00.000',
      currency: MoneyCurrency.eur,
    );
    expect(fund.currencies, [MoneyCurrency.eur]);
    expect(fund.balanceIn(MoneyCurrency.eur), 0);
  });

  test('funds recorded before currencies existed are in dinars', () {
    final fund = SavingsFund.fromJson({
      'id': 'f',
      'name': 'Stari fond',
      'color': '#000000',
      'createdAt': '2026-09-01T00:00:00.000',
    });
    expect(fund.currency, MoneyCurrency.rsd);
    expect(fund.toJson()['currency'], 'rsd');
  });

  test('a fund from before several currencies keeps its money in its own',
      () {
    final fund = SavingsFund.fromJson({
      'id': 'f',
      'name': 'Devize',
      'color': '#000000',
      'createdAt': '2026-09-01T00:00:00.000',
      'currency': 'eur',
      'openingBalance': 1000,
      'entries': [
        {'id': 'e', 'amount': 200, 'description': '', 'date': '2026-09-02'},
      ],
    });
    expect(fund.openingBalances, {MoneyCurrency.eur: 1000});
    expect(fund.currencyOf(fund.entries.single), MoneyCurrency.eur);
    expect(fund.currencies, [MoneyCurrency.eur]);
    expect(fund.balanceIn(MoneyCurrency.eur), 1200);
    expect(fund.balanceIn(MoneyCurrency.rsd), 0);
  });

  test('totals are kept per currency', () {
    SavingsFund fund(String id, MoneyCurrency c, double opening,
            List<Transaction> entries) =>
        SavingsFund(
          id: id,
          name: id,
          color: '#000000',
          createdAt: '2026-09-01T00:00:00.000',
          openingBalances: {c: opening},
          currency: c,
          entries: entries,
        );
    final totals = SavingsTotals.of([
      fund('a', MoneyCurrency.rsd, 50000, [
        const Transaction(
            id: 'a1', amount: 2000, description: '', date: '2026-10-02T10:00:00.000'),
      ]),
      fund('b', MoneyCurrency.eur, 1000, [
        const Transaction(
            id: 'b1', amount: 100, description: '', date: '2026-10-03T10:00:00.000'),
        const Transaction(
            id: 'b2', amount: -30, description: '', date: '2026-09-20T10:00:00.000'),
      ]),
    ], DateTime(2026, 10, 15));

    expect(totals.map((t) => t.currency), [MoneyCurrency.rsd, MoneyCurrency.eur]);
    expect(totals[0].balance, 52000);
    expect(totals[0].thisMonth, 2000);
    expect(totals[1].balance, 1070);
    expect(totals[1].thisMonth, 100);
  });
}
