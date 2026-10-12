import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/app_data.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/loan.dart';
import 'package:budget_tracker/models/loan_direction.dart';
import 'package:budget_tracker/models/money_currency.dart';
import 'package:budget_tracker/models/savings_fund.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/services/monthly_rollover.dart';

Transaction _tx(String id, double amount, String date) =>
    Transaction(id: id, amount: amount, description: '', date: date);

void main() {
  test('rollover archives income and savings, and carries them over', () {
    final data = AppData(
      currentCategories: [
        Category(
          id: 'c',
          name: 'Hrana',
          budget: 40000,
          color: '#FF6B6B',
          createdAt: '2026-09-01T00:00:00.000',
          transactions: [_tx('t', 12000, '2026-09-10T12:00:00.000')],
        ),
      ],
      monthlyReports: [],
      lastResetDate: '2026-09-01T00:00:00.000',
      monthlyIncome: 120000,
      savingsFunds: [
        SavingsFund(
          id: 'f',
          name: 'Hitni fond',
          color: '#4ECDC4',
          createdAt: '2026-08-01T00:00:00.000',
          openingBalances: {MoneyCurrency.rsd: 100000},
          entries: [
            _tx('a', 5000, '2026-08-20T12:00:00.000'), // previous month
            _tx('b', 20000, '2026-09-05T12:00:00.000'),
            _tx('c', -3000, '2026-09-25T12:00:00.000'),
          ],
        ),
      ],
      loans: [
        Loan(
          id: 'l',
          person: 'Marko',
          direction: LoanDirection.lent,
          amount: 10000,
          date: '2026-09-02T12:00:00.000',
        ),
      ],
    );

    final ran = const MonthlyRollover()
        .apply(data, now: DateTime(2026, 10, 1, 8));

    expect(ran, isTrue);
    final report = data.monthlyReports.single;
    expect(report.month, '2026-09');
    final dinars = report.totalsIn(MoneyCurrency.rsd);
    expect(dinars.income, 120000);
    expect(dinars.saved, 17000);
    expect(dinars.spent, 12000);
    expect(report.totals.keys, [MoneyCurrency.rsd]);

    // Categories reset; income, savings and loans carry over untouched.
    expect(data.currentCategories.single.transactions, isEmpty);
    expect(data.monthlyIncome, 120000);
    expect(data.savingsFunds.single.balanceIn(MoneyCurrency.rsd), 122000);
    expect(data.loans.single.remaining, 10000);
  });

  test('savings are archived per currency', () {
    final data = AppData(
      currentCategories: [
        Category(
          id: 'c',
          name: 'Hrana',
          budget: 1000,
          color: '#FF6B6B',
          createdAt: '2026-09-01T00:00:00.000',
        ),
      ],
      monthlyReports: [],
      lastResetDate: '2026-09-01T00:00:00.000',
      savingsFunds: [
        SavingsFund(
          id: 'rsd',
          name: 'Dinari',
          color: '#000000',
          createdAt: '2026-09-01T00:00:00.000',
          entries: [_tx('d', 4000, '2026-09-05T10:00:00.000')],
        ),
        SavingsFund(
          id: 'eur',
          name: 'Devize',
          color: '#000000',
          createdAt: '2026-09-01T00:00:00.000',
          currency: MoneyCurrency.eur,
          entries: [_tx('e', 300, '2026-09-06T10:00:00.000')],
        ),
        // One fund with both: each entry counts in its own currency.
        SavingsFund(
          id: 'both',
          name: 'Hitni fond',
          color: '#000000',
          createdAt: '2026-09-01T00:00:00.000',
          entries: [
            _tx('f', 1000, '2026-09-07T10:00:00.000'),
            Transaction(
                id: 'g',
                amount: 50,
                description: '',
                date: '2026-09-08T10:00:00.000',
                currency: MoneyCurrency.eur),
          ],
        ),
      ],
    );

    expect(const MonthlyRollover().apply(data, now: DateTime(2026, 10, 1)),
        isTrue);
    final report = data.monthlyReports.single;
    expect(report.totalsIn(MoneyCurrency.rsd).saved, 5000);
    expect(report.totalsIn(MoneyCurrency.eur).saved, 350);
  });
}
