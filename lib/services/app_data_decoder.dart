import '../models/app_data.dart';
import '../models/category.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/fixed_cost.dart';
import '../models/loan.dart';
import '../models/month_key.dart';
import '../models/monthly_report.dart';
import '../models/savings_fund.dart';
import '../models/transaction.dart';
import 'user_collections.dart';
import 'user_documents.dart';

/// Assembles the Firestore documents of an account into the [AppData] the
/// screens work with: entries are attached back to their category, fund or
/// loan, and every list is put back in a stable order. A document that does
/// not parse is skipped rather than hiding all the others.
class AppDataDecoder {
  const AppDataDecoder();

  /// Only the expenses of the open budget month (the profile's currentMonth,
  /// or [fallbackMonth] while there is no profile) are attached.
  AppData decode(UserDocuments docs, {required String fallbackMonth}) {
    final profile = docs.profile;
    final month = (profile?['currentMonth'] as String?) ?? fallbackMonth;

    final expenses = _transactions(
        docs[UserCollections.expensesName], 'categoryId',
        where: (doc) => doc['month'] == month);
    final entries =
        _transactions(docs[UserCollections.savingsEntriesName], 'fundId');
    final repayments =
        _transactions(docs[UserCollections.loanRepaymentsName], 'loanId');
    final items = _grouped(
      docs[UserCollections.checklistItemsName],
      'listId',
      ChecklistItem.fromJson,
      (a, b) => _byThenId(a.createdAt, b.createdAt, a.id, b.id),
    );

    final categories =
        _parse(docs[UserCollections.categoriesName], Category.fromJson)
          ..sort((a, b) => _byThenId(a.createdAt, b.createdAt, a.id, b.id));
    for (final c in categories) {
      c.transactions = expenses[c.id] ?? [];
    }

    final funds =
        _parse(docs[UserCollections.savingsFundsName], SavingsFund.fromJson)
          ..sort((a, b) => _byThenId(a.createdAt, b.createdAt, a.id, b.id));
    for (final f in funds) {
      f.entries = entries[f.id] ?? [];
    }

    final loans = _parse(docs[UserCollections.loansName], Loan.fromJson)
      ..sort((a, b) => _byThenId(a.date, b.date, a.id, b.id));
    for (final l in loans) {
      l.repayments = repayments[l.id] ?? [];
    }

    final fixedDocs = [...docs[UserCollections.fixedCostsName]]..sort((a, b) {
        final byOrder =
            ((a['order'] as num?) ?? 0).compareTo((b['order'] as num?) ?? 0);
        return byOrder != 0
            ? byOrder
            : (a['id'] as String).compareTo(b['id'] as String);
      });

    final reports =
        _parse(docs[UserCollections.reportsName], MonthlyReport.fromJson)
          ..sort((a, b) => b.month.compareTo(a.month));

    final checklists =
        _parse(docs[UserCollections.checklistsName], Checklist.fromJson)
          ..sort((a, b) => _byThenId(a.createdAt, b.createdAt, a.id, b.id));
    for (final c in checklists) {
      c.items = items[c.id] ?? [];
    }

    return AppData(
      currentCategories: categories,
      monthlyReports: reports,
      fixedCosts: _parse(fixedDocs, FixedCost.fromJson),
      lastResetDate: (monthStart(month) ?? DateTime.now()).toIso8601String(),
      monthlyIncome: (profile?['monthlyIncome'] as num?)?.toDouble() ?? 0,
      savingsFunds: funds,
      loans: loans,
      checklists: checklists,
    );
  }

  /// Transactions grouped by the parent id stored under [parentKey], each
  /// group sorted by date.
  static Map<String, List<Transaction>> _transactions(
    List<Map<String, dynamic>> docs,
    String parentKey, {
    bool Function(Map<String, dynamic> doc)? where,
  }) =>
      _grouped(docs, parentKey, Transaction.fromJson,
          (a, b) => _byThenId(a.date, b.date, a.id, b.id),
          where: where);

  /// Documents grouped by the parent id stored under [parentKey], each group
  /// sorted with [compare].
  static Map<String, List<T>> _grouped<T>(
    List<Map<String, dynamic>> docs,
    String parentKey,
    T Function(Map<String, dynamic>) fromJson,
    int Function(T, T) compare, {
    bool Function(Map<String, dynamic> doc)? where,
  }) {
    final groups = <String, List<T>>{};
    for (final doc in docs) {
      final parent = doc[parentKey];
      if (parent is! String || (where != null && !where(doc))) continue;
      final value = _tryParse(doc, fromJson);
      if (value != null) groups.putIfAbsent(parent, () => []).add(value);
    }
    for (final list in groups.values) {
      list.sort(compare);
    }
    return groups;
  }

  static List<T> _parse<T>(
    List<Map<String, dynamic>> docs,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      [
        for (final doc in docs) ?_tryParse(doc, fromJson),
      ];

  static T? _tryParse<T>(
    Map<String, dynamic> doc,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      return fromJson(doc);
    } catch (_) {
      return null;
    }
  }

  static int _byThenId(String a, String b, String idA, String idB) {
    final byValue = a.compareTo(b);
    return byValue != 0 ? byValue : idA.compareTo(idB);
  }
}
