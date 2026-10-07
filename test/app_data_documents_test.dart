import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/app_data.dart';
import 'package:budget_tracker/services/app_data_decoder.dart';
import 'package:budget_tracker/services/app_data_encoder.dart';
import 'package:budget_tracker/services/user_collections.dart';
import 'package:budget_tracker/services/user_documents.dart';

/// A full account, every list already in the order the decoder restores.
AppData _sample() => AppData.fromJson({
      'currentCategories': [
        {
          'id': 'c1',
          'name': 'Hrana',
          'budget': 40000,
          'color': '#FF6B6B',
          'createdAt': '2026-09-01T10:00:00.000',
          'transactions': [
            {'id': 't1', 'amount': 1200, 'description': 'pijaca', 'date': '2026-10-02T09:00:00.000'},
            {'id': 't2', 'amount': 800, 'description': '', 'date': '2026-10-03T18:30:00.000'},
          ],
        },
        {
          'id': 'c2',
          'name': 'Prevoz',
          'budget': 8000,
          'color': '#4ECDC4',
          'createdAt': '2026-09-02T10:00:00.000',
          'transactions': [],
        },
      ],
      'monthlyReports': [
        {
          'id': '2026-09',
          'month': '2026-09',
          'categories': [
            {
              'id': 'c1',
              'name': 'Hrana',
              'budget': 40000,
              'color': '#FF6B6B',
              'createdAt': '2026-09-01T10:00:00.000',
              'transactions': [
                {'id': 'old', 'amount': 38000, 'description': '', 'date': '2026-09-10T10:00:00.000'},
              ],
            },
          ],
          'totalBudget': 40000,
          'totalSpent': 38000,
          'totalRemaining': 2000,
          'income': 120000,
          'saved': 10000,
          'savedAt': '2026-10-01T08:00:00.000',
        },
      ],
      'fixedCosts': [
        {'id': 'f2', 'name': 'Kirija', 'amount': 30000},
        {'id': 'f1', 'name': 'Internet', 'amount': 2490},
      ],
      'lastResetDate': '2026-10-01T00:00:00.000',
      'monthlyIncome': 120000,
      'savingsFunds': [
        {
          'id': 's1',
          'name': 'Hitni fond',
          'color': '#000000',
          'createdAt': '2026-09-05T10:00:00.000',
          'target': 200000,
          'openingBalance': 50000,
          'entries': [
            {'id': 'e1', 'amount': 10000, 'description': '', 'date': '2026-09-20T10:00:00.000'},
            {'id': 'e2', 'amount': -3000, 'description': 'popravka', 'date': '2026-10-04T10:00:00.000'},
          ],
        },
      ],
      'loans': [
        {
          'id': 'l1',
          'person': 'Marko',
          'direction': 'lent',
          'amount': 10000,
          'date': '2026-09-12T10:00:00.000',
          'note': 'gorivo',
          'repayments': [
            {'id': 'r1', 'amount': 4000, 'description': '', 'date': '2026-09-30T10:00:00.000'},
          ],
        },
      ],
    });

void main() {
  const encoder = AppDataEncoder();
  const decoder = AppDataDecoder();

  test('an account survives the trip to documents and back unchanged', () {
    final data = _sample();
    final docs = encoder.encode(data);

    expect(docs.profile, {'currentMonth': '2026-10', 'monthlyIncome': 120000});
    expect(docs[UserCollections.expensesName].map((d) => d['month']),
        everyElement('2026-10'));
    expect(docs[UserCollections.categoriesName].first.containsKey('spent'),
        isFalse);

    final back = decoder.decode(docs, fallbackMonth: '2026-10');
    expect(back.toJson(), data.toJson());
  });

  test('only the open month\'s expenses are attached to the categories', () {
    final docs = encoder.encode(_sample());
    docs[UserCollections.expensesName].add({
      'id': 'late',
      'amount': 99,
      'description': '',
      'date': '2026-09-30T23:00:00.000',
      'categoryId': 'c1',
      'month': '2026-09',
    });

    final back = decoder.decode(docs, fallbackMonth: '2026-10');
    expect(back.currentCategories.first.transactions.map((t) => t.id),
        ['t1', 't2']);
  });

  test('a document that does not parse is skipped, not fatal', () {
    final docs = encoder.encode(_sample());
    docs[UserCollections.loansName].add({'id': 'broken'});

    final back = decoder.decode(docs, fallbackMonth: '2026-10');
    expect(back.loans.map((l) => l.id), ['l1']);
  });

  test('without a profile the fallback month is open and income unset', () {
    final encoded = encoder.encode(_sample());
    final back = decoder.decode(
      UserDocuments(collections: encoded.collections),
      fallbackMonth: '2026-11',
    );
    expect(back.lastResetDate, startsWith('2026-11'));
    expect(back.monthlyIncome, 0);
    // The October expenses are not part of the open (November) month.
    expect(back.currentCategories.first.transactions, isEmpty);
  });
}
