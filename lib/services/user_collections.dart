import 'package:cloud_firestore/cloud_firestore.dart';

/// Where one account's data lives in Firestore: its own document
/// (users/{uid}, the profile) and one subcollection per kind of record. The
/// security rules allow exactly these collections, and only to the owner.
class UserCollections {
  UserCollections(this._db, this.uid);

  final FirebaseFirestore _db;
  final String uid;

  static const String categoriesName = 'categories';
  static const String expensesName = 'expenses';
  static const String fixedCostsName = 'fixedCosts';
  static const String savingsFundsName = 'savingsFunds';
  static const String savingsEntriesName = 'savingsEntries';
  static const String loansName = 'loans';
  static const String loanRepaymentsName = 'loanRepayments';
  static const String reportsName = 'reports';
  static const String checklistsName = 'checklists';
  static const String checklistItemsName = 'checklistItems';

  /// Every subcollection, in the order the live view subscribes to them.
  static const List<String> names = [
    categoriesName,
    expensesName,
    fixedCostsName,
    savingsFundsName,
    savingsEntriesName,
    loansName,
    loanRepaymentsName,
    reportsName,
    checklistsName,
    checklistItemsName,
  ];

  DocumentReference<Map<String, dynamic>> get profile =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      profile.collection(name);

  CollectionReference<Map<String, dynamic>> get categories =>
      collection(categoriesName);
  CollectionReference<Map<String, dynamic>> get expenses =>
      collection(expensesName);
  CollectionReference<Map<String, dynamic>> get fixedCosts =>
      collection(fixedCostsName);
  CollectionReference<Map<String, dynamic>> get savingsFunds =>
      collection(savingsFundsName);
  CollectionReference<Map<String, dynamic>> get savingsEntries =>
      collection(savingsEntriesName);
  CollectionReference<Map<String, dynamic>> get loans =>
      collection(loansName);
  CollectionReference<Map<String, dynamic>> get loanRepayments =>
      collection(loanRepaymentsName);
  CollectionReference<Map<String, dynamic>> get reports =>
      collection(reportsName);
  CollectionReference<Map<String, dynamic>> get checklists =>
      collection(checklistsName);
  CollectionReference<Map<String, dynamic>> get checklistItems =>
      collection(checklistItemsName);

  WriteBatch batch() => _db.batch();
}
