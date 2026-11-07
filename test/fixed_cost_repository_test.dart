import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/app_data.dart';
import 'package:budget_tracker/services/budget_repository.dart';
import 'package:budget_tracker/services/fixed_cost_repository.dart';

import 'fake_account.dart';

void main() {
  test('adds, updates and deletes fixed costs, keeping their order', () async {
    final repo = FixedCostRepository(await openFakeSession());

    final rent = await repo.addFixedCost('Kirija', 30000);
    await repo.addFixedCost('Internet', 2500);
    await settle();
    expect((await repo.fixedCosts()).map((c) => c.name),
        ['Kirija', 'Internet']);

    await repo.updateFixedCost(rent.id, name: 'Stan', amount: 32000);
    await settle();
    final updated = (await repo.fixedCosts()).first;
    expect(updated.name, 'Stan');
    expect(updated.amount, 32000);

    await repo.deleteFixedCost(rent.id);
    await settle();
    expect((await repo.fixedCosts()).map((c) => c.name), ['Internet']);
  });

  test('fixed costs survive closing the month', () async {
    var now = DateTime(2026, 9, 15);
    final session = await openFakeSession(clock: () => now);
    final budget = BudgetRepository(session);
    final fixed = FixedCostRepository(session);

    final food = await budget.addCategory('Hrana', 40000);
    await budget.addExpense(food.id, 500, '');
    await fixed.addFixedCost('Kirija', 30000);
    await settle();

    now = DateTime(2026, 10, 1, 8);
    session.closer.check();
    await settle();

    expect((await budget.monthlyReports()).single.month, '2026-09');
    expect((await budget.currentCategories()).single.transactions, isEmpty);
    expect((await fixed.fixedCosts()).single.name, 'Kirija');
  });

  test('fixed costs kept on the phone move to the account', () async {
    final session = await openFakeSession();
    await moveLocalData(session, {
      'currentCategories': [],
      'monthlyReports': [],
      'lastResetDate': DateTime.now().toIso8601String(),
      'fixedCosts': [
        {'id': 'f1', 'name': 'Struja', 'amount': 4200},
      ],
    });
    final costs = await FixedCostRepository(session).fixedCosts();
    expect(costs.single.name, 'Struja');
    expect(costs.single.amount, 4200);
  });

  test('on-phone data from before fixed costs has none', () {
    final data = AppData.fromJson({
      'currentCategories': [],
      'monthlyReports': [],
      'lastResetDate': '2026-09-01T00:00:00.000Z',
    });
    expect(data.fixedCosts, isEmpty);
  });
}
