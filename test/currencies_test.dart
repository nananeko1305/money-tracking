import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/budget_totals.dart';
import 'package:budget_tracker/models/currency_sums.dart';
import 'package:budget_tracker/models/income_totals.dart';
import 'package:budget_tracker/models/money_currency.dart';
import 'package:budget_tracker/services/app_data_decoder.dart';
import 'package:budget_tracker/services/budget_repository.dart';
import 'package:budget_tracker/services/checklist_repository.dart';
import 'package:budget_tracker/services/fixed_cost_repository.dart';
import 'package:budget_tracker/services/savings_repository.dart';
import 'package:budget_tracker/services/user_collections.dart';
import 'package:budget_tracker/services/user_documents.dart';

import 'fake_account.dart';

/// Dinars and euros across the whole app: every amount has a currency, and
/// every total is kept per currency, never converted.
void main() {
  test('a euro category keeps its expenses in euros, totalled apart',
      () async {
    final budget = BudgetRepository(await openFakeSession());
    final food = await budget.addCategory('Hrana', 40000);
    final trip = await budget.addCategory('Putovanje', 500,
        currency: MoneyCurrency.eur);
    await budget.addExpense(food.id, 1500, '');
    await budget.addExpense(trip.id, 120, 'hotel');
    await settle();

    final categories = await budget.currentCategories();
    expect(categories.last.currency, MoneyCurrency.eur);
    expect(categories.last.spent, 120);

    final totals = BudgetTotals.of(categories);
    expect(totals.map((t) => t.currency),
        [MoneyCurrency.rsd, MoneyCurrency.eur]);
    expect(totals[0].remaining, 38500);
    expect(totals[1].remaining, 380);

    await budget.updateCategory(trip.id, currency: MoneyCurrency.rsd);
    await settle();
    expect(BudgetTotals.of(await budget.currentCategories()).single.spent,
        1620);
  });

  test('each income only carries its own currency, fixed costs included',
      () async {
    final session = await openFakeSession();
    final budget = BudgetRepository(session);
    final savings = SavingsRepository(session);
    final fixedCosts = FixedCostRepository(session);
    await fixedCosts.addFixedCost('Kirija', 30000);
    await fixedCosts.addFixedCost('Netflix', 13, currency: MoneyCurrency.eur);
    await budget.setMonthlyIncome(rsd: 120000, eur: 1000);
    await budget.addCategory('Hrana', 40000);
    final trip = await budget.addCategory('Putovanje', 500,
        currency: MoneyCurrency.eur);
    await budget.addExpense(trip.id, 120, '');
    final fund = await savings.addFund('Devize', currency: MoneyCurrency.eur);
    await savings.deposit(fund.id, 100, '');
    await settle();

    final incomes = await budget.monthlyIncomes();
    final totals = IncomeTotals.of(
      incomeIn: (c) => incomes[c] ?? 0,
      budgets: BudgetTotals.of(await budget.currentCategories()),
      fixed: sumByCurrency(
          await fixedCosts.fixedCosts(), (c) => c.currency, (c) => c.amount),
      saved: await savings.netSavedInMonth(DateTime.now()),
    );
    expect(totals.map((t) => t.currency),
        [MoneyCurrency.rsd, MoneyCurrency.eur]);
    expect(totals[0].unallocated, 50000); // 120000 − 40000 − 30000 fixed
    expect(totals[0].left, 90000); // nothing spent, 30000 fixed
    expect(totals[1].unallocated, 387); // 1000 − 500 − 13 fixed − 100 saved
    expect(totals[1].left, 767); // 1000 − 120 spent − 13 fixed − 100 saved
  });

  test('closing the month reports each currency on its own', () async {
    final today = DateTime.now();
    var now = today;
    final session = await openFakeSession(clock: () => now);
    final budget = BudgetRepository(session);
    await budget.setMonthlyIncome(rsd: 0, eur: 1000);
    await FixedCostRepository(session)
        .addFixedCost('Kirija', 300, currency: MoneyCurrency.eur);
    final food = await budget.addCategory('Hrana', 40000);
    final trip = await budget.addCategory('Putovanje', 500,
        currency: MoneyCurrency.eur);
    await budget.addExpense(food.id, 1500, '');
    await budget.addExpense(trip.id, 120, '');
    await settle();

    now = DateTime(today.year, today.month + 1, 1, 8);
    session.closer.check();
    await settle();

    final report = (await budget.monthlyReports()).single;
    expect(report.totals.keys, [MoneyCurrency.rsd, MoneyCurrency.eur]);
    expect(report.totalsIn(MoneyCurrency.rsd).spent, 1500);
    expect(report.totalsIn(MoneyCurrency.rsd).income, 0);
    expect(report.totalsIn(MoneyCurrency.eur).spent, 120);
    expect(report.totalsIn(MoneyCurrency.eur).income, 1000);
    expect(report.totalsIn(MoneyCurrency.eur).fixed, 300);
    expect(report.totalsIn(MoneyCurrency.rsd).fixed, 0);
    expect(report.categories.last.currency, MoneyCurrency.eur);
  });

  test('fixed costs are totalled per currency', () async {
    final repo = FixedCostRepository(await openFakeSession());
    await repo.addFixedCost('Kirija', 300, currency: MoneyCurrency.eur);
    await repo.addFixedCost('Struja', 4200);
    await repo.addFixedCost('Netflix', 13, currency: MoneyCurrency.eur);
    await settle();

    final costs = await repo.fixedCosts();
    expect(sumByCurrency(costs, (c) => c.currency, (c) => c.amount),
        {MoneyCurrency.rsd: 4200, MoneyCurrency.eur: 313});
  });

  test('a list keeps its planned amounts in its currency', () async {
    final repo = ChecklistRepository(await openFakeSession());
    final trip = await repo.addChecklist('More', currency: MoneyCurrency.eur);
    await repo.addItem(trip.id, 'Apartman', 450);
    await settle();
    expect((await repo.checklists()).single.currency, MoneyCurrency.eur);

    await repo.updateChecklist(trip.id, currency: MoneyCurrency.rsd);
    await settle();
    expect((await repo.checklists()).single.currency, MoneyCurrency.rsd);
  });

  test('documents written before currencies existed read as dinars', () {
    final data = const AppDataDecoder().decode(
      UserDocuments(
        profile: {'currentMonth': '2026-10', 'monthlyIncome': 90000},
        collections: {
          UserCollections.categoriesName: [
            {
              'id': 'c',
              'name': 'Hrana',
              'budget': 40000,
              'color': '#FF6B6B',
              'createdAt': '2026-10-01T00:00:00.000',
            },
          ],
          UserCollections.fixedCostsName: [
            {'id': 'f', 'name': 'Kirija', 'amount': 30000, 'order': 0},
          ],
          UserCollections.checklistsName: [
            {'id': 'k', 'name': 'Market', 'createdAt': '2026-10-01T00:00:00.000'},
          ],
        },
      ),
      fallbackMonth: '2026-10',
    );

    expect(data.currentCategories.single.currency, MoneyCurrency.rsd);
    expect(data.fixedCosts.single.currency, MoneyCurrency.rsd);
    expect(data.checklists.single.currency, MoneyCurrency.rsd);
    expect(data.incomeIn(MoneyCurrency.rsd), 90000);
    expect(data.incomeIn(MoneyCurrency.eur), 0);
  });
}
