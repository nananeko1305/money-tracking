import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/app_data.dart';
import 'package:budget_tracker/models/loan.dart';
import 'package:budget_tracker/models/loan_direction.dart';
import 'package:budget_tracker/models/monthly_report.dart';
import 'package:budget_tracker/models/savings_fund.dart';
import 'package:budget_tracker/models/transaction.dart';

void main() {
  test('income, savings and loans survive a JSON round trip', () {
    final data = AppData(
      currentCategories: [],
      monthlyReports: [
        const MonthlyReport(
          id: '2026-09',
          month: '2026-09',
          categories: [],
          totalBudget: 0,
          totalSpent: 0,
          totalRemaining: 0,
          savedAt: '2026-10-01T00:00:00.000',
          income: 120000,
          saved: 15000,
        ),
      ],
      lastResetDate: '2026-10-01T00:00:00.000',
      monthlyIncome: 130000,
      savingsFunds: [
        SavingsFund(
          id: 'f',
          name: 'Hitni fond',
          color: '#4ECDC4',
          createdAt: '2026-10-01T00:00:00.000',
          target: 200000,
          openingBalance: 30000,
          entries: [
            const Transaction(
                id: 'e', amount: -500, description: 'x', date: '2026-10-02'),
          ],
        ),
      ],
      loans: [
        Loan(
          id: 'l',
          person: 'Ana',
          direction: LoanDirection.borrowed,
          amount: 7000,
          date: '2026-10-03T00:00:00.000',
          note: 'kafa',
          repayments: [
            const Transaction(
                id: 'r', amount: 2000, description: '', date: '2026-10-04'),
          ],
        ),
      ],
    );

    final copy = AppData.fromJson(
        jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>);

    expect(copy.monthlyIncome, 130000);
    expect(copy.monthlyReports.single.income, 120000);
    expect(copy.monthlyReports.single.saved, 15000);
    final fund = copy.savingsFunds.single;
    expect(fund.target, 200000);
    expect(fund.openingBalance, 30000);
    expect(fund.balance, 29500);
    final loan = copy.loans.single;
    expect(loan.direction, LoanDirection.borrowed);
    expect(loan.note, 'kafa');
    expect(loan.remaining, 5000);
    expect(copy.isEmpty, isFalse);
  });

  test('isEmpty is true only when nothing at all is recorded', () {
    expect(AppData.empty().isEmpty, isTrue);
    expect((AppData.empty()..monthlyIncome = 1).isEmpty, isFalse);
  });
}
