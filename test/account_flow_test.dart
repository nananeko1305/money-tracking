import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';
import 'package:budget_tracker/services/legacy_local_data.dart';

/// Sign-in, sign-out and moving the on-phone data to the account, through
/// the real UI.
void main() {
  final ana = MockUser(uid: 'ana', email: 'ana@example.com');

  setUp(() => SharedPreferences.setMockInitialValues({'onboarding_seen': true}));

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'tajna123');
    await tapText(tester, 'Prijavi se');
  }

  testWidgets('signing in opens the app, signing out returns to login',
      (tester) async {
    await tester.pumpWidget(AppRoot(
      auth: MockFirebaseAuth(mockUser: ana),
      firestore: FakeFirebaseFirestore(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Prijavi se nalogom koji ti je napravio admin.'),
        findsOneWidget);

    await signIn(tester);
    await tapText(tester, 'Ne sada'); // empty account: no backup restore
    expect(find.text('Dodaj kategoriju'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    // The account section sits below the fold of the test screen.
    await tester.scrollUntilVisible(
      find.text('Odjavi se'),
      100,
      scrollable: find.descendant(
          of: find.byType(Drawer), matching: find.byType(Scrollable)),
    );
    await tester.ensureVisible(find.text('Odjavi se'));
    await tester.pumpAndSettle();
    expect(find.text('ana@example.com'), findsOneWidget);
    await tapText(tester, 'Odjavi se'); // drawer item
    await tapText(tester, 'Odjavi se'); // confirm
    expect(find.text('Prijavi se nalogom koji ti je napravio admin.'),
        findsOneWidget);
  });

  testWidgets('a wrong password is explained', (tester) async {
    final auth = MockFirebaseAuth(mockUser: ana);
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(auth)
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    await tester.pumpWidget(
        AppRoot(auth: auth, firestore: FakeFirebaseFirestore()));
    await tester.pumpAndSettle();

    await signIn(tester);
    expect(find.text('Pogrešan email ili lozinka.'), findsOneWidget);
  });

  /// What the app kept on the phone before accounts existed.
  final legacyBlob = jsonEncode({
    'currentCategories': [
      {
        'id': 'c1',
        'name': 'Stara kategorija',
        'budget': 15000,
        'color': '#FF6B6B',
        'createdAt': '2026-10-01T10:00:00.000',
        'transactions': [
          {'id': 't1', 'amount': 700, 'description': 'hleb', 'date': '2026-10-02T10:00:00.000'},
        ],
      },
    ],
    'monthlyReports': [],
    'lastResetDate': DateTime.now().toIso8601String(),
  });

  Future<String?> legacyOnPhone(WidgetTester tester) async =>
      (await tester.runAsync(SharedPreferences.getInstance))!
          .getString('budget_app_data');

  testWidgets('the on-phone data is moved to an empty account, and kept',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'onboarding_seen': true, 'budget_app_data': legacyBlob});
    await tester.pumpWidget(AppRoot(
      auth: MockFirebaseAuth(signedIn: true, mockUser: ana),
      firestore: FakeFirebaseFirestore(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Prenesi podatke na nalog'), findsOneWidget);
    await tapText(tester, 'Prenesi');
    expect(find.text('Stara kategorija'), findsOneWidget);
    expect(await tester.runAsync(() => LegacyLocalData().pending()), isNull);
    // Moving never deletes or rewrites what is on the phone.
    expect(await legacyOnPhone(tester), legacyBlob);
  });

  testWidgets('declining the move leaves the on-phone data and asks again',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'onboarding_seen': true, 'budget_app_data': legacyBlob});
    await tester.pumpWidget(AppRoot(
      auth: MockFirebaseAuth(signedIn: true, mockUser: ana),
      firestore: FakeFirebaseFirestore(),
    ));
    await tester.pumpAndSettle();

    await tapText(tester, 'Ne sada'); // the move
    await tapText(tester, 'Ne sada'); // then the backup-file restore
    expect(await legacyOnPhone(tester), legacyBlob);
    expect(await tester.runAsync(() => LegacyLocalData().pending()), isNotNull);
  });

  test('empty or already moved on-phone data is not offered', () async {
    SharedPreferences.setMockInitialValues({
      'budget_app_data': jsonEncode({
        'currentCategories': [],
        'monthlyReports': [],
        'lastResetDate': '2026-10-01T00:00:00.000',
      }),
    });
    expect(await LegacyLocalData().pending(), isNull);

    SharedPreferences.setMockInitialValues({
      'budget_app_data': jsonEncode({
        'currentCategories': [],
        'monthlyReports': [],
        'monthlyIncome': 90000,
      }),
    });
    final legacy = LegacyLocalData();
    expect(await legacy.pending(), isNotNull);
    await legacy.markMoved('ana');
    expect(await legacy.pending(), isNull);
  });
}
