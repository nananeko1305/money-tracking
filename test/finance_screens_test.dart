import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';

/// Drives the income, savings and loans flows through the real UI, on a
/// phone-sized screen so layout overflows would fail the test.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'onboarding_seen': true}));

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
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
    // An empty account first offers to restore a backup; decline it.
    await tapText(tester, 'Ne sada');
  }

  testWidgets('setting the monthly income shows the breakdown',
      (tester) async {
    await pumpApp(tester);

    await tapText(tester, 'Unesi prihod');
    await tester.enterText(
        find.widgetWithText(TextField, 'Dinari'), '120000');
    await tapText(tester, 'Sačuvaj');

    // With no categories yet, income, unallocated and left are all equal.
    expect(find.text('120.000 din'), findsNWidgets(3));
    expect(find.text('Neraspoređeno:'), findsOneWidget);
    expect(find.text('Preostalo od prihoda:'), findsOneWidget);

    // Editing keeps the full value (Serbian display groups with '.').
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '120000'), findsOneWidget);
    await tapText(tester, 'Sačuvaj');
    expect(find.text('120.000 din'), findsNWidgets(3));

    // Fixed costs come out of the income too.
    await tester.tap(find.byIcon(Icons.receipt_long));
    await tester.pumpAndSettle();
    await tapText(tester, 'Dodaj fiksni trošak');
    await tester.enterText(find.byType(TextField).at(0), 'Kirija');
    await tester.enterText(find.byType(TextField).at(1), '30000');
    await tapText(tester, 'Sačuvaj');
    await tester.tap(find.byIcon(Icons.account_balance_wallet));
    await tester.pumpAndSettle();
    expect(find.text('Fiksni troškovi:'), findsOneWidget);
    expect(find.text('90.000 din'), findsNWidgets(2)); // unallocated, left

    // A category budget is allocated out of the income.
    await tapText(tester, 'Dodaj kategoriju');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(fields.evaluate().length - 2), 'Hrana');
    await tester.enterText(fields.last, '40000');
    await tapText(tester, 'Sačuvaj');
    expect(find.text('50.000 din'), findsOneWidget); // unallocated
  });

  testWidgets('the dashboard keeps dinars and euros apart', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Unesi prihod');
    await tester.enterText(
        find.widgetWithText(TextField, 'Dinari'), '120000');
    await tester.enterText(find.widgetWithText(TextField, 'Evri'), '1000');
    await tapText(tester, 'Sačuvaj');
    expect(find.text('120.000 din'), findsNWidgets(3));
    expect(find.text('1.000 €'), findsNWidgets(3));

    // A category in euros comes out of the euro income only.
    await tester.dragUntilVisible(find.text('Dodaj kategoriju'),
        find.byType(ListView).hitTestable().first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tapText(tester, 'Dodaj kategoriju');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(fields.evaluate().length - 2), 'More');
    await tester.enterText(fields.last, '500');
    await tapText(tester, 'Evri');
    await tapText(tester, 'Sačuvaj');
    expect(find.text('120.000 din'), findsNWidgets(3)); // dinars untouched
    expect(find.text('500 €'), findsWidgets); // allocated, unallocated, ...

    // An expense in the euro category, entered on its card.
    final amount = find.widgetWithText(TextField, 'Iznos');
    await tester.dragUntilVisible(amount,
        find.byType(ListView).hitTestable().first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.enterText(amount, '120');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('880 €'),
        find.byType(ListView).hitTestable().first, const Offset(0, 300));
    expect(find.text('880 €'), findsOneWidget); // left of the euro income
    expect(find.text('120 € (24%)', skipOffstage: false), findsOneWidget);
    expect(find.text('120.000 din'), findsNWidgets(3));
  });

  testWidgets('savings: add a fund, deposit and withdraw', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.savings));
    await tester.pumpAndSettle();
    expect(find.text('Još nema štednje'), findsOneWidget);

    await tapText(tester, 'Dodaj štednju');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Hitni fond');
    await tester.enterText(fields.at(1), '50000');
    await tester.enterText(fields.at(2), '200000');
    await tapText(tester, 'Sačuvaj');

    expect(find.text('Hitni fond'), findsOneWidget);
    expect(find.text('25% cilja'), findsOneWidget);

    await tapText(tester, 'Uplati');
    await tester.enterText(find.byType(TextField).first, '10000');
    await tapText(tester, 'Uplati');
    expect(find.text('+10.000 din'), findsOneWidget); // this month

    await tapText(tester, 'Podigni');
    await tester.enterText(find.byType(TextField).first, '999999');
    await tapText(tester, 'Podigni');
    expect(find.text('Na štednji nema toliko novca'), findsOneWidget);
    expect(find.text('60.000 din'), findsWidgets);
  });

  testWidgets('savings in euros are totalled apart and leave the income alone',
      (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Unesi prihod');
    await tester.enterText(
        find.widgetWithText(TextField, 'Dinari'), '120000');
    await tapText(tester, 'Sačuvaj');

    await tester.tap(find.byIcon(Icons.savings));
    await tester.pumpAndSettle();
    await tapText(tester, 'Dodaj štednju');
    await tester.enterText(find.byType(TextField).at(0), 'Devize');
    await tapText(tester, 'Evri');
    await tester.enterText(find.byType(TextField).at(1), '1000');
    expect(find.text('€'), findsNWidgets(2)); // opening balance and goal
    await tapText(tester, 'Sačuvaj');
    expect(find.text('1.000 €'), findsWidgets);

    await tapText(tester, 'Uplati');
    expect(find.text('€'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '100');
    await tapText(tester, 'Uplati');
    expect(find.text('+100 €'), findsOneWidget); // this month, in euros
    expect(find.text('1.100 €'), findsWidgets);

    // The dinar income is untouched by the euro deposit.
    await tester.tap(find.byIcon(Icons.account_balance_wallet));
    await tester.pumpAndSettle();
    expect(find.text('120.000 din'), findsNWidgets(3));
  });

  testWidgets('loans: add a loan, repay part, overview updates',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.handshake));
    await tester.pumpAndSettle();
    expect(find.text('Nema pozajmica'), findsOneWidget);

    await tapText(tester, 'Dodaj pozajmicu');
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Marko');
    await tester.enterText(fields.at(1), '10000');
    await tapText(tester, 'Sačuvaj');

    expect(find.text('Marko'), findsOneWidget);
    expect(find.text('+10.000 din'), findsOneWidget); // net balance

    await tapText(tester, 'Vraćanje');
    await tester.enterText(find.byType(TextField).first, '4000');
    await tapText(tester, 'Sačuvaj');

    expect(find.text('4.000 din'), findsOneWidget); // repaid
    expect(find.text('+6.000 din'), findsOneWidget); // net balance
  });

  testWidgets('loans in euros are totalled apart from dinars', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.handshake));
    await tester.pumpAndSettle();

    await tapText(tester, 'Dodaj pozajmicu');
    var fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Marko');
    await tester.enterText(fields.at(1), '10000');
    await tapText(tester, 'Sačuvaj');

    await tapText(tester, 'Dodaj pozajmicu');
    await tapText(tester, 'Ja dugujem');
    fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Banka');
    await tester.enterText(fields.at(1), '500');
    await tapText(tester, 'Evri');
    expect(find.text('€'), findsOneWidget); // the amount field's suffix
    await tapText(tester, 'Sačuvaj');

    expect(find.text('+10.000 din'), findsOneWidget); // net in dinars
    expect(find.text('-500 €'), findsOneWidget); // net in euros

    // A repayment is entered in the loan's own currency.
    await tester.ensureVisible(find.text('Vraćanje').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vraćanje').last);
    await tester.pumpAndSettle();
    expect(find.text('€'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '200');
    await tapText(tester, 'Sačuvaj');
    // Back up to the summary card.
    await tester.dragUntilVisible(find.text('-300 €'),
        find.byType(ListView).hitTestable().first, const Offset(0, 300));
    expect(find.text('-300 €'), findsOneWidget);
    expect(find.text('+10.000 din'), findsOneWidget);
  });
}
