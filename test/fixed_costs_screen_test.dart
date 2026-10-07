import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/app_scope.dart';
import 'package:budget_tracker/l10n/strings.dart';
import 'package:budget_tracker/screens/fixed_costs_screen.dart';
import 'package:budget_tracker/services/fixed_cost_repository.dart';
import 'package:budget_tracker/theme.dart';

Widget _host(FixedCostRepository repo) => AppScope(
      strings: AppStrings.of('sr'),
      localeCode: 'sr',
      themeMode: ThemeMode.light,
      setLocale: (_) {},
      setThemeMode: (_) {},
      child: MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(body: FixedCostsScreen(storage: repo)),
      ),
    );

Future<void> _addViaDialog(
    WidgetTester tester, String name, String amount) async {
  await tester.tap(find.text('Dodaj fiksni trošak'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), name);
  await tester.enterText(find.byType(TextField).at(1), amount);
  await tester.tap(find.text('Sačuvaj'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists fixed costs with their monthly total', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = FixedCostRepository();

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();
    expect(find.text('Nema fiksnih troškova'), findsOneWidget);

    await _addViaDialog(tester, 'Kirija', '30000');
    await _addViaDialog(tester, 'Internet', '2500');

    expect(find.text('Kirija'), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
    expect(find.text('Ukupno mesečno:'), findsOneWidget);
    expect(find.text('32.500 din'), findsOneWidget);

    // Delete "Internet" through its close button and the confirm dialog.
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Obriši'));
    await tester.pumpAndSettle();

    expect(find.text('Internet'), findsNothing);
    expect(find.text('30.000 din'), findsNWidgets(2)); // row + total
  });
}
