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

/// Turns app models into the Firestore documents of an account. Documents keep
/// the models' own JSON shape, so backups and migrations need no conversion,
/// and add only what the flat layout needs: the parent id of an entry, the
/// budget month of an expense and the list position of a fixed cost.
class AppDataEncoder {
  const AppDataEncoder();

  Map<String, dynamic> profile({
    required String currentMonth,
    required double monthlyIncome,
  }) =>
      {'currentMonth': currentMonth, 'monthlyIncome': monthlyIncome};

  Map<String, dynamic> category(Category c) => c.toJson()
    ..remove('transactions')
    ..remove('spent');

  Map<String, dynamic> expense(
    Transaction t, {
    required String categoryId,
    required String month,
  }) =>
      {...t.toJson(), 'categoryId': categoryId, 'month': month};

  /// [order] keeps the list in the order the user entered it; fixed costs
  /// have no date to sort by.
  Map<String, dynamic> fixedCost(FixedCost c, {required int order}) =>
      {...c.toJson(), 'order': order};

  Map<String, dynamic> savingsFund(SavingsFund f) =>
      f.toJson()..remove('entries');

  Map<String, dynamic> savingsEntry(Transaction t, {required String fundId}) =>
      {...t.toJson(), 'fundId': fundId};

  Map<String, dynamic> loan(Loan l) => l.toJson()..remove('repayments');

  Map<String, dynamic> loanRepayment(Transaction t, {required String loanId}) =>
      {...t.toJson(), 'loanId': loanId};

  Map<String, dynamic> report(MonthlyReport r) => r.toJson();

  Map<String, dynamic> checklist(Checklist c) => c.toJson()..remove('items');

  Map<String, dynamic> checklistItem(ChecklistItem i, {required String listId}) =>
      {...i.toJson(), 'listId': listId};

  /// Every document [data] maps to. The live transactions of its categories
  /// belong to the budget month its lastResetDate falls in.
  UserDocuments encode(AppData data) {
    final month =
        monthKey(DateTime.tryParse(data.lastResetDate) ?? DateTime.now());
    return UserDocuments(
      profile: profile(currentMonth: month, monthlyIncome: data.monthlyIncome),
      collections: {
        UserCollections.categoriesName: [
          for (final c in data.currentCategories) category(c),
        ],
        UserCollections.expensesName: [
          for (final c in data.currentCategories)
            for (final t in c.transactions)
              expense(t, categoryId: c.id, month: month),
        ],
        UserCollections.fixedCostsName: [
          for (final (i, c) in data.fixedCosts.indexed) fixedCost(c, order: i),
        ],
        UserCollections.savingsFundsName: [
          for (final f in data.savingsFunds) savingsFund(f),
        ],
        UserCollections.savingsEntriesName: [
          for (final f in data.savingsFunds)
            for (final e in f.entries) savingsEntry(e, fundId: f.id),
        ],
        UserCollections.loansName: [for (final l in data.loans) loan(l)],
        UserCollections.loanRepaymentsName: [
          for (final l in data.loans)
            for (final r in l.repayments) loanRepayment(r, loanId: l.id),
        ],
        UserCollections.reportsName: [
          for (final r in data.monthlyReports) report(r),
        ],
        UserCollections.checklistsName: [
          for (final c in data.checklists) checklist(c),
        ],
        UserCollections.checklistItemsName: [
          for (final c in data.checklists)
            for (final i in c.items) checklistItem(i, listId: c.id),
        ],
      },
    );
  }
}
