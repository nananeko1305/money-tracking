import '../models/app_data.dart';
import '../models/loan.dart';
import '../models/loan_direction.dart';
import '../models/transaction.dart';
import 'app_data_store.dart';
import 'id_generator.dart';

/// CRUD for loans (money lent or borrowed) and their repayments. Loans live in
/// the same persisted [AppData] blob as the budget, so backups include them,
/// but they are independent of the monthly budget and the rollover.
class LoanRepository {
  LoanRepository({AppDataStore? store, IdGenerator? ids})
      : _store = store ?? AppDataStore(),
        _ids = ids ?? IdGenerator();

  final AppDataStore _store;
  final IdGenerator _ids;

  Loan? _loanById(AppData data, String id) {
    for (final l in data.loans) {
      if (l.id == id) return l;
    }
    return null;
  }

  Future<List<Loan>> loans() async => (await _store.read()).loans;

  Future<Loan> addLoan({
    required String person,
    required LoanDirection direction,
    required double amount,
    String note = '',
  }) async {
    final data = await _store.read();
    final loan = Loan(
      id: _ids.next(),
      person: person,
      direction: direction,
      amount: amount,
      note: note.trim(),
      date: DateTime.now().toIso8601String(),
    );
    data.loans.add(loan);
    await _store.write(data);
    return loan;
  }

  Future<void> updateLoan(
    String id, {
    String? person,
    LoanDirection? direction,
    double? amount,
    String? note,
  }) async {
    final data = await _store.read();
    final loan = _loanById(data, id);
    if (loan == null) return;
    if (person != null) loan.person = person;
    if (direction != null) loan.direction = direction;
    if (amount != null) loan.amount = amount;
    if (note != null) loan.note = note.trim();
    await _store.write(data);
  }

  Future<void> deleteLoan(String id) async {
    final data = await _store.read();
    data.loans.removeWhere((l) => l.id == id);
    await _store.write(data);
  }

  Future<void> addRepayment(
      String loanId, double amount, String description) async {
    final data = await _store.read();
    final loan = _loanById(data, loanId);
    if (loan == null) return;
    loan.repayments.add(Transaction(
      id: _ids.next(),
      amount: amount,
      description: description.trim(),
      date: DateTime.now().toIso8601String(),
    ));
    await _store.write(data);
  }

  Future<void> deleteRepayment(String loanId, String repaymentId) async {
    final data = await _store.read();
    final loan = _loanById(data, loanId);
    if (loan == null) return;
    loan.repayments.removeWhere((r) => r.id == repaymentId);
    await _store.write(data);
  }
}
