import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/loan_direction.dart';
import 'package:budget_tracker/services/budget_repository.dart';
import 'package:budget_tracker/services/loan_repository.dart';

import 'fake_account.dart';

void main() {
  test('an edit on one phone shows up on the other', () async {
    final db = FakeFirebaseFirestore();
    final phoneA = await openFakeSession(firestore: db);
    final phoneB = await openFakeSession(firestore: db);
    var notified = 0;
    phoneB.live.addListener(() => notified++);

    final food = await BudgetRepository(phoneA).addCategory('Hrana', 40000);
    await BudgetRepository(phoneA).addExpense(food.id, 950, 'hleb');
    await LoanRepository(phoneA).addLoan(
        person: 'Marko', direction: LoanDirection.lent, amount: 5000);
    await settle();

    final onB = await BudgetRepository(phoneB).currentCategories();
    expect(onB.single.spent, 950);
    expect((await LoanRepository(phoneB).loans()).single.person, 'Marko');
    expect(notified, greaterThan(0));
  });

  test('a fresh account is confirmed empty by the server', () async {
    final session = await openFakeSession();
    expect(await session.live.isEmptyOnServer(), isTrue);

    await BudgetRepository(session).addCategory('Hrana', 1000);
    await settle();
    expect(await session.live.isEmptyOnServer(), isFalse);
  });
}
