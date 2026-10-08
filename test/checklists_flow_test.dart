import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';

/// The checklists through the real UI, on a phone-sized screen so layout
/// overflows would fail the test.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'onboarding_seen': true}));

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> addItem(WidgetTester tester, String name, String amount) async {
    await tapText(tester, 'Dodaj stavku');
    await tester.enterText(find.byType(TextField).at(0), name);
    await tester.enterText(find.byType(TextField).at(1), amount);
    await tapText(tester, 'Sačuvaj');
  }

  testWidgets('make a list, add items, tick one off', (tester) async {
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
    await tapText(tester, 'Ne sada'); // empty account: no backup restore

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tapText(tester, 'Spiskovi');
    expect(find.text('Nema spiskova'), findsOneWidget);

    await tapText(tester, 'Dodaj spisak');
    await tester.enterText(find.byType(TextField), 'Market');
    await tapText(tester, 'Sačuvaj');
    expect(find.text('0 od 0'), findsOneWidget);

    await tapText(tester, 'Market');
    expect(find.text('Spisak je prazan'), findsOneWidget);
    await addItem(tester, 'Mleko', '200');
    await addItem(tester, 'Hleb', '80');
    await addItem(tester, 'Kesa', ''); // no price yet
    expect(find.text('280 din'), findsNWidgets(2)); // total and left

    await tester.tap(find.byType(Checkbox).first); // Mleko
    await tester.pumpAndSettle();
    expect(find.text('280 din'), findsOneWidget); // total
    expect(find.text('80 din'), findsNWidgets(2)); // left, and Hleb's row

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('1 od 3'), findsOneWidget);
  });
}
