import 'package:flutter/foundation.dart' show Listenable;

import '../models/loan.dart';
import '../models/loan_direction.dart';
import '../models/transaction.dart';
import 'app_data_encoder.dart';
import 'batch_commits.dart';
import 'id_generator.dart';
import 'user_collections.dart';
import 'user_session.dart';

/// CRUD for the signed-in account's loans (money lent or borrowed) and their
/// repayments. They are independent of the monthly budget and untouched when
/// a month is closed. Writes are not awaited (see [WriteErrors]).
class LoanRepository {
  LoanRepository(
    this._session, {
    IdGenerator? ids,
    this._encoder = const AppDataEncoder(),
  }) : _ids = ids ?? IdGenerator();

  final UserSession _session;
  final IdGenerator _ids;
  final AppDataEncoder _encoder;

  UserCollections get _docs => _session.docs;

  void _write(Future<void> write) => _session.writes.track(write);

  /// Notifies whenever the account's data changes, on this phone or another.
  Listenable get changes => _session.live;

  Future<List<Loan>> loans() async => (await _session.live.ready()).loans;

  Future<Loan> addLoan({
    required String person,
    required LoanDirection direction,
    required double amount,
    String note = '',
  }) async {
    final loan = Loan(
      id: _ids.next(),
      person: person,
      direction: direction,
      amount: amount,
      note: note.trim(),
      date: DateTime.now().toIso8601String(),
    );
    _write(_docs.loans.doc(loan.id).set(_encoder.loan(loan)));
    return loan;
  }

  Future<void> updateLoan(
    String id, {
    String? person,
    LoanDirection? direction,
    double? amount,
    String? note,
  }) async {
    _write(_docs.loans.doc(id).update({
      'person': ?person,
      if (direction != null) 'direction': direction.name,
      'amount': ?amount,
      if (note != null) 'note': note.trim(),
    }));
  }

  /// Deletes the loan together with its repayments.
  Future<void> deleteLoan(String id) async {
    final repayments =
        _session.live.documents[UserCollections.loanRepaymentsName];
    commitInBatches(_docs, _session.writes, [
      (b) => b.delete(_docs.loans.doc(id)),
      for (final doc in repayments)
        if (doc['loanId'] == id)
          (b) => b.delete(_docs.loanRepayments.doc(doc['id'] as String)),
    ]);
  }

  Future<void> addRepayment(
      String loanId, double amount, String description) async {
    final repayment = Transaction(
      id: _ids.next(),
      amount: amount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    );
    _write(_docs.loanRepayments
        .doc(repayment.id)
        .set(_encoder.loanRepayment(repayment, loanId: loanId)));
  }

  Future<void> deleteRepayment(String loanId, String repaymentId) async =>
      _write(_docs.loanRepayments.doc(repaymentId).delete());
}
