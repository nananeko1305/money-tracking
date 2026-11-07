import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';

void main() {
  testWidgets('App renders the dashboard title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});

    await tester.pumpWidget(AppRoot(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'ana', email: 'ana@example.com'),
      ),
      firestore: FakeFirebaseFirestore(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Money Tracking'), findsWidgets);
    await tester.dragUntilVisible(find.text('Dodaj kategoriju'),
        find.byType(ListView).hitTestable().first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Dodaj kategoriju'), findsOneWidget);
  });
}
