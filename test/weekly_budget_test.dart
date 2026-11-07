import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';
import 'package:budget_tracker/models/money_currency.dart';
import 'package:budget_tracker/services/budget_repository.dart';

import 'fake_account.dart';

void main() {
  test('the weekly budget and weekly limits are kept on the account', () async {
    final db = FakeFirebaseFirestore();
    final budget = BudgetRepository(await openFakeSession(firestore: db));

    await budget.setWeeklyBudget(rsd: 15000, eur: 100);
    final food = await budget.addCategory('Hrana', 40000, weeklyLimit: 8000);
    await budget.addExpense(food.id, 1200, 'pijaca');
    await settle();

    // A second phone on the same account sees all of it.
    final other = BudgetRepository(await openFakeSession(firestore: db));
    expect(await other.weeklyBudgets(),
        {MoneyCurrency.rsd: 15000, MoneyCurrency.eur: 100});
    expect((await other.currentCategories()).single.weeklyLimit, 8000);
    final week = await other.weeklySpending();
    expect(week.inCategory(food.id), 1200);
    expect(week.inCurrency(MoneyCurrency.rsd), 1200);

    await budget.updateCategory(food.id, weeklyLimit: 0);
    await budget.setWeeklyBudget(rsd: 0, eur: 0);
    await settle();
    expect((await other.currentCategories()).single.weeklyLimit, 0);
    expect(await other.weeklyBudgets(),
        {MoneyCurrency.rsd: 0, MoneyCurrency.eur: 0});
  });

  testWidgets('going past a weekly limit warns but keeps the expense',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppRoot(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'ana', email: 'ana@example.com'),
      ),
      firestore: FakeFirebaseFirestore(),
    ));
    await tester.pumpAndSettle();

    Future<void> tapText(String text) async {
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    Future<void> scrollTo(Finder finder) async {
      await tester.dragUntilVisible(finder,
          find.byType(ListView).hitTestable().first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    Future<void> addExpense(String amount) async {
      final field = find.widgetWithText(TextField, 'Iznos');
      await scrollTo(field);
      await tester.enterText(field, amount);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    await scrollTo(find.text('Postavi nedeljni budžet'));
    await tapText('Postavi nedeljni budžet');
    await tester.enterText(find.widgetWithText(TextField, 'Dinari'), '10000');
    await tapText('Sačuvaj');
    expect(find.text('10.000 din'), findsNWidgets(2)); // budget, left
    expect(find.text('Ostalo za ovu nedelju:'), findsOneWidget);

    await scrollTo(find.text('Dodaj kategoriju'));
    await tapText('Dodaj kategoriju');
    await tester.enterText(find.widgetWithText(TextField, 'Naziv'), 'Hrana');
    await tester.enterText(find.widgetWithText(TextField, 'Budžet'), '40000');
    await tester.enterText(
        find.widgetWithText(TextField, 'Nedeljni limit'), '3000');
    await tapText('Sačuvaj');
    await scrollTo(find.text('Ove nedelje:'));
    expect(find.text('0 od 3.000 din'), findsOneWidget);

    await addExpense('2000');
    expect(find.byType(SnackBar), findsNothing);

    await addExpense('1500');
    expect(find.text('Hrana: 500 din preko nedeljnog limita'), findsOneWidget);
    expect(find.text('3.500 od 3.000 din'), findsOneWidget);

    await addExpense('7000');
    expect(
        find.text('Hrana: 7.500 din preko nedeljnog limita\n'
            'Nedeljni budžet: 500 din preko'),
        findsOneWidget);

    // Every expense was kept, and the weekly card counts all of them.
    await tester.dragUntilVisible(find.text('Potrošeno ove nedelje:'),
        find.byType(ListView).hitTestable().first, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('10.500 din', skipOffstage: false), findsWidgets);
    expect(find.text('-500 din', skipOffstage: false), findsOneWidget);
  });
}
