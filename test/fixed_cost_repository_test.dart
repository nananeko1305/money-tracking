import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/services/budget_repository.dart';
import 'package:budget_tracker/services/fixed_cost_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('adds, updates and deletes fixed costs', () async {
    final repo = FixedCostRepository();

    final rent = await repo.addFixedCost('Kirija', 30000);
    await repo.addFixedCost('Internet', 2500);
    expect((await repo.fixedCosts()).map((c) => c.name),
        ['Kirija', 'Internet']);

    await repo.updateFixedCost(rent.id, name: 'Stan', amount: 32000);
    final updated = (await repo.fixedCosts()).first;
    expect(updated.name, 'Stan');
    expect(updated.amount, 32000);

    await repo.deleteFixedCost(rent.id);
    expect((await repo.fixedCosts()).map((c) => c.name), ['Internet']);
  });

  test('fixed costs survive the monthly rollover', () async {
    SharedPreferences.setMockInitialValues({
      'budget_app_data': jsonEncode({
        'currentCategories': [
          {
            'id': '1',
            'name': 'Hrana',
            'budget': 40000,
            'color': '#FF6B6B',
            'createdAt': '2020-01-01T00:00:00.000',
            'transactions': [
              {'id': 't1', 'amount': 500, 'date': '2020-01-05T00:00:00.000'},
            ],
          },
        ],
        'monthlyReports': [],
        'fixedCosts': [
          {'id': 'f1', 'name': 'Kirija', 'amount': 30000},
        ],
        'lastResetDate': '2020-01-01T00:00:00.000',
      }),
    });

    // Reading through the budget repository triggers the rollover.
    final budget = BudgetRepository();
    expect((await budget.monthlyReports()).length, 1);
    expect((await budget.currentCategories()).first.transactions, isEmpty);

    final costs = await FixedCostRepository().fixedCosts();
    expect(costs.single.name, 'Kirija');
    expect(costs.single.amount, 30000);
  });

  test('fixed costs round-trip through backup export / import', () async {
    await FixedCostRepository().addFixedCost('Struja', 4200);
    final exported = await BudgetRepository().exportJson();

    SharedPreferences.setMockInitialValues({});
    expect(await FixedCostRepository().fixedCosts(), isEmpty);

    expect(await BudgetRepository().importJson(exported), isTrue);
    final costs = await FixedCostRepository().fixedCosts();
    expect(costs.single.name, 'Struja');
    expect(costs.single.amount, 4200);
  });

  test('a backup without fixed costs imports with an empty list', () async {
    final ok = await BudgetRepository().importJson(jsonEncode({
      'currentCategories': [],
      'monthlyReports': [],
      'lastResetDate': '2026-09-01T00:00:00.000Z',
    }));
    expect(ok, isTrue);
    expect(await FixedCostRepository().fixedCosts(), isEmpty);
  });
}
