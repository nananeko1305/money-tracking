import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';
import 'package:budget_tracker/services/release_links.dart';
import 'package:budget_tracker/widgets/qr_code_view.dart';

void main() {
  testWidgets('the drawer shares a QR code and a copyable download link',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await tester.pumpWidget(AppRoot(
      auth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'ana', email: 'ana@example.com'),
      ),
      firestore: FakeFirebaseFirestore(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ne sada').last); // empty account
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Podeli aplikaciju'), 100,
        scrollable: find.descendant(
            of: find.byType(Drawer), matching: find.byType(Scrollable)));
    await tester.ensureVisible(find.text('Podeli aplikaciju'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Podeli aplikaciju'));
    await tester.pumpAndSettle();

    final qr = tester.widget<QrCodeView>(find.byType(QrCodeView));
    expect(qr.data, ReleaseLinks.latestApk);
    expect(find.text(ReleaseLinks.latestApk), findsOneWidget);

    await tester.tap(find.text('Kopiraj link'));
    await tester.pumpAndSettle();
    expect(copied, ReleaseLinks.latestApk);
    expect(find.text('Link je kopiran'), findsOneWidget);

    await tester.tap(find.text('Zatvori'));
    await tester.pumpAndSettle();
    expect(find.byType(QrCodeView), findsNothing);
  });

  test('the shared link points at the APK the release workflow publishes', () {
    final workflow =
        File('.github/workflows/release-apk.yml').readAsStringSync();
    final apkName =
        RegExp(r'^\s*APK_NAME:\s*(\S+)', multiLine: true).firstMatch(workflow)!;
    expect(ReleaseLinks.latestApk, endsWith('/latest/download/${apkName[1]}'));
  });
}
