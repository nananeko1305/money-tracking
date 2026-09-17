import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/main.dart';

void main() {
  testWidgets('App renders the dashboard title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    expect(find.text('Money Tracking'), findsWidgets);
    expect(find.text('Dodaj kategoriju'), findsOneWidget);
  });
}
