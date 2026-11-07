import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/money_currency.dart';
import 'package:budget_tracker/models/monthly_report.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/models/week.dart';
import 'package:budget_tracker/models/weekly_spending.dart';

Category _category(
  String id,
  List<(String id, double amount, String date)> spent, {
  double weeklyLimit = 0,
  MoneyCurrency currency = MoneyCurrency.rsd,
}) =>
    Category(
      id: id,
      name: id,
      budget: 40000,
      weeklyLimit: weeklyLimit,
      color: '#000000',
      createdAt: '2026-09-01T10:00:00.000',
      currency: currency,
      transactions: [
        for (final (tid, amount, date) in spent)
          Transaction(id: tid, amount: amount, description: '', date: date),
      ],
    );

MonthlyReport _report(String month, List<Category> categories) => MonthlyReport(
      id: month,
      month: month,
      categories: categories,
      savedAt: '$month-28T00:00:00.000',
    );

void main() {
  test('a week runs from Monday to Sunday', () {
    final monday = DateTime(2026, 11, 2);
    expect(weekStart(DateTime(2026, 11, 4, 15, 30)), monday);
    expect(weekStart(DateTime(2026, 11, 8, 23, 59)), monday);
    expect(weekStart(monday), monday);
    expect(weekStart(DateTime(2026, 12, 2)), DateTime(2026, 11, 30));
    expect(daysUntilNextWeek(monday), 7);
    expect(daysUntilNextWeek(DateTime(2026, 11, 8)), 1);
  });

  test('only expenses since Monday count, per category and currency', () {
    final food = _category('food', [
      ('t1', 1000, '2026-11-01T22:00:00.000'), // Sunday, last week
      ('t2', 1500, '2026-11-02T08:00:00.000'), // Monday
      ('t3', 700, '2026-11-07T12:00:00.000'),
    ]);
    final trip = _category('trip', [('t4', 50, '2026-11-03T10:00:00.000')],
        currency: MoneyCurrency.eur);

    final week = WeeklySpending.of([food, trip], const [],
        now: DateTime(2026, 11, 7, 18));

    expect(week.inCategory('food'), 2200);
    expect(week.inCategory('trip'), 50);
    expect(week.inCategory('missing'), 0);
    expect(week.inCurrency(MoneyCurrency.rsd), 2200);
    expect(week.inCurrency(MoneyCurrency.eur), 50);
    expect(week.daysLeft, 2);
  });

  test('a week that began last month reads that month from its report', () {
    final now = DateTime(2026, 12, 2, 9); // Wednesday; the week began Nov 30
    final food = _category('food', [('dec', 400, '2026-12-01T10:00:00.000')]);
    final november = _report('2026-11', [
      _category('food', [
        ('nov29', 9000, '2026-11-29T10:00:00.000'), // Sunday, last week
        ('nov30', 600, '2026-11-30T10:00:00.000'),
        ('dec', 400, '2026-12-01T10:00:00.000'), // also still live: once
      ]),
      _category('gone', [('nov30b', 100, '2026-11-30T11:00:00.000')]),
    ]);
    final october = _report('2026-10', [
      _category('food', [('oct', 5000, '2026-11-30T10:00:00.000')]),
    ]);

    final week =
        WeeklySpending.of([food], [november, october], now: now);

    expect(week.inCategory('food'), 1000);
    expect(week.inCategory('gone'), 100);
    expect(week.inCurrency(MoneyCurrency.rsd), 1100);
  });

  test('an expense past a weekly limit reports by how much', () {
    final food = _category('food', [('t1', 4500, '2026-11-03T10:00:00.000')],
        weeklyLimit: 5000);
    final fun = _category('fun', [('t2', 300, '2026-11-04T10:00:00.000')]);
    final week = WeeklySpending.of([food, fun], const [],
        now: DateTime(2026, 11, 5));

    expect(week.overrunAfter(food, 400, budget: 0),
        (category: 0.0, budget: 0.0));
    expect(week.overrunAfter(food, 1000, budget: 0),
        (category: 500.0, budget: 0.0));
    // 4800 spent across categories; the weekly budget is 5000.
    expect(week.overrunAfter(fun, 1000, budget: 5000),
        (category: 0.0, budget: 800.0));
    expect(week.overrunAfter(food, 1000, budget: 5000),
        (category: 500.0, budget: 800.0));
  });
}
