import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app.dart';

void main() {
  testWidgets('App renders the dashboard title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    expect(find.text('Money Tracking'), findsWidgets);
    expect(find.text('Dodaj kategoriju'), findsOneWidget);
  });
}
