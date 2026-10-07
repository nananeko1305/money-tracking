import 'loan_strings.dart';

/// Serbian (Latin) loan strings.
mixin LoanStringsSr implements LoanStrings {
  @override
  String get navLoans => 'Pozajmice';
  @override
  String get owedToMe => 'Duguju meni';
  @override
  String get iOwe => 'Ja dugujem';
  @override
  String get loansNet => 'Bilans:';
  @override
  String get addLoan => 'Dodaj pozajmicu';
  @override
  String get newLoan => 'Nova pozajmica';
  @override
  String get editLoan => 'Izmeni pozajmicu';
  @override
  String get loanPerson => 'Osoba';
  @override
  String get loanPersonHint => 'npr. Marko';
  @override
  String get loanAmount => 'Iznos:';
  @override
  String get loanAmountHint => 'npr. 10000';
  @override
  String get loanNoteHint => 'Napomena (opciono)';
  @override
  String get loanRepaid => 'Vraćeno:';
  @override
  String get recordRepayment => 'Vraćanje';
  @override
  String get repaymentTitle => 'Vraćanje pozajmice';
  @override
  String get repaymentEntry => 'Vraćanje';
  @override
  String get loanSettled => 'Izmireno';
  @override
  String get settledLoans => 'Izmirene pozajmice';
  @override
  String get invalidLoan => 'Unesi ime osobe i validan iznos';
  @override
  String get repaymentTooLarge => 'Iznos je veći od preostalog duga';
  @override
  String get noLoans => 'Nema pozajmica';
  @override
  String get noLoansSub =>
      'Beleži ko tebi duguje i kome ti duguješ, i prati vraćanje.';
  @override
  String get noRepayments => 'Još ništa nije vraćeno';
  @override
  String get loanNotFound => 'Pozajmica nije pronađena';
  @override
  String get deleteLoanTitle => 'Obriši pozajmicu';

  @override
  String deleteLoanMsg(String person) =>
      'Da li želiš da obrišeš pozajmicu za "$person"?';
}
