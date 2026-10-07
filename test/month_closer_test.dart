import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/month_key.dart';
import 'package:budget_tracker/services/budget_repository.dart';
import 'package:budget_tracker/services/savings_repository.dart';
import 'package:budget_tracker/services/user_collections.dart';

import 'fake_account.dart';

void main() {
  late DateTime now;
  setUp(() => now = DateTime(2026, 9, 15));

  test('a new account starts its first month', () async {
    final db = FakeFirebaseFirestore();
    await openFakeSession(firestore: db, clock: () => now);

    final profile = await db.collection('users').doc(testUid).get();
    expect(profile.data(), {'currentMonth': '2026-09', 'monthlyIncome': 0});
  });

  test('closing archives the month once and starts the next', () async {
    // Entries are dated with the real clock, so this month is the open one.
    final today = DateTime.now();
    now = today;
    final open = monthKey(today);
    final session = await openFakeSession(clock: () => now);
    final budget = BudgetRepository(session);
    final savings = SavingsRepository(session);

    await budget.setMonthlyIncome(120000);
    final food = await budget.addCategory('Hrana', 40000);
    await budget.addExpense(food.id, 1500, 'pijaca');
    final fund = await savings.addFund('Hitni fond');
    await savings.deposit(fund.id, 10000, '');
    await settle();

    now = DateTime(today.year, today.month + 1, 1, 8);
    session.closer.check();
    session.closer.check(); // a second check must not close again
    await settle();

    final report = (await budget.monthlyReports()).single;
    expect(report.month, open);
    expect(report.totalSpent, 1500);
    expect(report.income, 120000);
    expect(report.saved, 10000);
    expect(report.categories.single.transactions.single.description, 'pijaca');

    expect(session.live.openMonth, monthKey(now));
    expect((await budget.currentCategories()).single.transactions, isEmpty);
    final expenses =
        await session.docs.collection(UserCollections.expensesName).get();
    expect(expenses.docs, isEmpty);
  });

  test('two phones closing the same month leave one report', () async {
    final db = FakeFirebaseFirestore();
    final phoneA = await openFakeSession(firestore: db, clock: () => now);
    final budget = BudgetRepository(phoneA);
    final food = await budget.addCategory('Hrana', 40000);
    await budget.addExpense(food.id, 700, '');
    await settle();
    final phoneB = await openFakeSession(firestore: db, clock: () => now);

    now = DateTime(2026, 10, 2);
    phoneA.closer.check();
    phoneB.closer.check();
    await settle();

    final reports = await db
        .collection('users')
        .doc(testUid)
        .collection(UserCollections.reportsName)
        .get();
    expect(reports.docs.map((d) => d.id), ['2026-09']);
    expect(phoneB.live.openMonth, '2026-10');
  });

  test('a month without categories moves on without a report', () async {
    final session = await openFakeSession(clock: () => now);
    now = DateTime(2026, 11, 3);
    session.closer.check();
    await settle();

    expect(session.live.openMonth, '2026-11');
    expect(await BudgetRepository(session).monthlyReports(), isEmpty);
  });

  test('only the last 12 reports are kept', () async {
    final session = await openFakeSession(clock: () => now);
    final budget = BudgetRepository(session);
    await budget.addCategory('Hrana', 40000);
    await settle();

    for (var month = 10; month <= 23; month++) {
      now = DateTime(2026, month, 1);
      session.closer.check();
      await settle();
    }

    final reports = await budget.monthlyReports();
    expect(reports, hasLength(12));
    expect(reports.first.month, '2027-10');
  });
}
