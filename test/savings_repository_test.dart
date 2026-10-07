import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/models/savings_fund.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/savings_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('balance is opening balance plus deposits minus withdrawals', () async {
    final repo = SavingsRepository();
    final fund = await repo.addFund('Hitni fond',
        target: 200000, openingBalance: 50000);

    await repo.deposit(fund.id, 20000, 'plata');
    await repo.withdraw(fund.id, 5000, '');

    final saved = (await repo.funds()).single;
    expect(saved.balance, 65000);
    expect(saved.entries.map((e) => e.amount), [20000, -5000]);
    expect(saved.percentOfTarget, closeTo(32.5, 1e-9));
  });

  test('this month counts entries only, never the opening balance', () async {
    final repo = SavingsRepository();
    final fund = await repo.addFund('Letovanje', openingBalance: 500000);
    await repo.deposit(fund.id, 10000, '');
    await repo.withdraw(fund.id, 3000, '');

    expect(await repo.netSavedInMonth(DateTime.now()), 7000);
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
    expect(fund.netInMonth(DateTime(2026, 9, 30)), 1000);
    expect(fund.netInMonth(DateTime(2026, 10, 1)), 2000);
  });

  test('update, delete entry and delete fund', () async {
    final repo = SavingsRepository();
    final fund = await repo.addFund('Auto');
    await repo.deposit(fund.id, 1000, '');
    await repo.updateFund(fund.id,
        name: 'Novi auto', target: 900000, openingBalance: 100);

    var saved = (await repo.funds()).single;
    expect(saved.name, 'Novi auto');
    expect(saved.target, 900000);
    expect(saved.balance, 1100);

    await repo.deleteEntry(fund.id, saved.entries.single.id);
    saved = (await repo.funds()).single;
    expect(saved.balance, 100);

    await repo.deleteFund(fund.id);
    expect(await repo.funds(), isEmpty);
  });
}
