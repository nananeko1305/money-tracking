import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget_tracker/services/budget_repository.dart';

void main() {
  // A backup produced by the Expo app's exportData(): each category carries a
  // single "legacy" transaction equal to its accumulated spent value.
  final expoExport = {
    'currentCategories': [
      {
        'id': '111',
        'name': 'Hrana',
        'budget': 40000,
        'spent': 12500,
        'color': '#FF6B6B',
        'createdAt': '2026-09-01T10:00:00.000Z',
        'transactions': [
          {
            'id': '111-legacy',
            'amount': 12500,
            'description': 'Prethodna potrošnja',
            'date': '2026-09-01T10:00:00.000Z',
          },
        ],
      },
      {
        'id': '222',
        'name': 'Prevoz',
        'budget': 8000,
        'spent': 0,
        'color': '#4ECDC4',
        'createdAt': '2026-09-01T10:00:00.000Z',
        'transactions': [],
      },
    ],
    'monthlyReports': [
      {
        'id': '2026-08',
        'month': '2026-08',
        'categories': [
          {
            'id': '333',
            'name': 'Hrana',
            'budget': 40000,
            'spent': 38000,
            'color': '#FF6B6B',
            'createdAt': '2026-08-01T10:00:00.000Z',
            'transactions': [
              {
                'id': '333-legacy',
                'amount': 38000,
                'description': 'Prethodna potrošnja',
                'date': '2026-08-01T10:00:00.000Z',
              },
            ],
          },
        ],
        'totalBudget': 40000,
        'totalSpent': 38000,
        'totalRemaining': 2000,
        'savedAt': '2026-09-01T00:00:00.000Z',
      },
    ],
    'lastResetDate': '2026-09-01T00:00:00.000Z',
  };

  test('Expo backup imports into Flutter with spent preserved', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = BudgetRepository();

    final ok = await storage.importJson(jsonEncode(expoExport));
    expect(ok, isTrue);

    final categories = await storage.currentCategories();
    expect(categories.length, 2);

    final hrana = categories.firstWhere((c) => c.name == 'Hrana');
    expect(hrana.spent, 12500); // derived from the legacy transaction
    expect(hrana.remaining, 27500);
    expect(hrana.transactions.length, 1);

    final prevoz = categories.firstWhere((c) => c.name == 'Prevoz');
    expect(prevoz.spent, 0);
    expect(prevoz.transactions, isEmpty);

    final reports = await storage.monthlyReports();
    expect(reports.length, 1);
    expect(reports.first.totalSpent, 38000);
    expect(reports.first.categories.first.spent, 38000);
  });
}
