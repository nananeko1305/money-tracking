import 'loan_strings.dart';

/// English loan strings.
mixin LoanStringsEn implements LoanStrings {
  @override
  String get navLoans => 'Loans';
  @override
  String get owedToMe => 'Owed to me';
  @override
  String get iOwe => 'I owe';
  @override
  String get loansNet => 'Net:';
  @override
  String get addLoan => 'Add loan';
  @override
  String get newLoan => 'New loan';
  @override
  String get editLoan => 'Edit loan';
  @override
  String get loanPerson => 'Person';
  @override
  String get loanPersonHint => 'e.g. Mark';
  @override
  String get loanAmount => 'Amount:';
  @override
  String get loanAmountHint => 'e.g. 10000';
  @override
  String get dinars => 'Dinars';
  @override
  String get euros => 'Euros';
  @override
  String get loanNoteHint => 'Note (optional)';
  @override
  String get loanRepaid => 'Repaid:';
  @override
  String get recordRepayment => 'Repayment';
  @override
  String get repaymentTitle => 'Loan repayment';
  @override
  String get repaymentEntry => 'Repayment';
  @override
  String get loanSettled => 'Settled';
  @override
  String get settledLoans => 'Settled loans';
  @override
  String get invalidLoan => 'Enter a name and a valid amount';
  @override
  String get repaymentTooLarge => 'That is more than what is left to repay';
  @override
  String get noLoans => 'No loans';
  @override
  String get noLoansSub =>
      'Track who owes you and whom you owe, and follow the repayments.';
  @override
  String get noRepayments => 'Nothing repaid yet';
  @override
  String get loanNotFound => 'Loan not found';
  @override
  String get deleteLoanTitle => 'Delete loan';

  @override
  String deleteLoanMsg(String person) =>
      'Delete the loan with "$person"?';
}
