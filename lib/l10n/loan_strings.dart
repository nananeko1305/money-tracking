/// Strings for the loans section. Mixed into [AppStrings]; each language
/// implements it in its own file.
mixin LoanStrings {
  String get navLoans;
  String get owedToMe;
  String get iOwe;
  String get loansNet;
  String get addLoan;
  String get newLoan;
  String get editLoan;
  String get loanPerson;
  String get loanPersonHint;
  String get loanAmount;
  String get loanAmountHint;
  String get dinars;
  String get euros;
  String get loanNoteHint;
  String get loanRepaid;
  String get recordRepayment;
  String get repaymentTitle;
  String get repaymentEntry;
  String get loanSettled;
  String get settledLoans;
  String get invalidLoan;
  String get repaymentTooLarge;
  String get noLoans;
  String get noLoansSub;
  String get noRepayments;
  String get loanNotFound;
  String get deleteLoanTitle;

  String deleteLoanMsg(String person);
}
