import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/app_data.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/models/loan.dart';
import 'package:budget_tracker/models/loan_direction.dart';
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
          openingBalance: 100000,
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
    expect(report.income, 120000);
    expect(report.saved, 17000);
    expect(report.totalSpent, 12000);

    // Categories reset; income, savings and loans carry over untouched.
    expect(data.currentCategories.single.transactions, isEmpty);
    expect(data.monthlyIncome, 120000);
    expect(data.savingsFunds.single.balance, 122000);
    expect(data.loans.single.remaining, 10000);
  });
}
