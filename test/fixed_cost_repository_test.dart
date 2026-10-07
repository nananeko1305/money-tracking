import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

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

  test('fixed costs round-trip through backup export / import', () async {
    final source = await openFakeSession();
    await FixedCostRepository(source).addFixedCost('Struja', 4200);
    await settle();
    final exported = await BudgetRepository(source).exportJson();

    final target = await openFakeSession();
    expect(await BudgetRepository(target).importJson(exported), isTrue);
    await settle();
    final costs = await FixedCostRepository(target).fixedCosts();
    expect(costs.single.name, 'Struja');
    expect(costs.single.amount, 4200);
  });

  test('a backup without fixed costs imports with an empty list', () async {
    final session = await openFakeSession();
    final ok = await BudgetRepository(session).importJson(jsonEncode({
      'currentCategories': [],
      'monthlyReports': [],
      'lastResetDate': '2026-09-01T00:00:00.000Z',
    }));
    expect(ok, isTrue);
    await settle();
    expect(await FixedCostRepository(session).fixedCosts(), isEmpty);
  });

  test('an invalid backup is rejected and changes nothing', () async {
    final session = await openFakeSession();
    await FixedCostRepository(session).addFixedCost('Kirija', 30000);
    await settle();

    expect(await BudgetRepository(session).importJson('{not json'), isFalse);
    await settle();
    expect(await FixedCostRepository(session).fixedCosts(), hasLength(1));
  });
}
