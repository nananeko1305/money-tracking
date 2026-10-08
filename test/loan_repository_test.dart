import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/loan.dart';
import 'package:budget_tracker/models/loan_direction.dart';
import 'package:budget_tracker/models/loan_totals.dart';
import 'package:budget_tracker/models/money_currency.dart';
import 'package:budget_tracker/services/loan_repository.dart';

import 'fake_account.dart';

void main() {
  Future<LoanRepository> openRepo() async =>
      LoanRepository(await openFakeSession());

  test('repayments reduce what is left until the loan is settled', () async {
    final repo = await openRepo();
    final loan = await repo.addLoan(
      person: 'Marko',
      direction: LoanDirection.lent,
      amount: 10000,
      note: ' za gorivo ',
    );

    await repo.addRepayment(loan.id, 4000, '');
    await settle();
    var saved = (await repo.loans()).single;
    expect(saved.note, 'za gorivo');
    expect(saved.repaid, 4000);
    expect(saved.remaining, 6000);
    expect(saved.isSettled, isFalse);
    expect(saved.percentRepaid, 40);

    await repo.addRepayment(loan.id, 6000, 'ostatak');
    await settle();
    saved = (await repo.loans()).single;
    expect(saved.remaining, 0);
    expect(saved.isSettled, isTrue);
  });

  test('decimal repayments settle despite floating point noise', () async {
    final repo = await openRepo();
    final loan = await repo.addLoan(
        person: 'Ana', direction: LoanDirection.borrowed, amount: 0.3);
    await repo.addRepayment(loan.id, 0.1, '');
    await repo.addRepayment(loan.id, 0.2, '');
    await settle();
    expect((await repo.loans()).single.isSettled, isTrue);
  });

  test('remaining never goes negative after editing the amount down', () async {
    final repo = await openRepo();
    final loan = await repo.addLoan(
        person: 'Ana', direction: LoanDirection.borrowed, amount: 5000);
    await repo.addRepayment(loan.id, 3000, '');
    await repo.updateLoan(loan.id, amount: 2000);

    await settle();
    final saved = (await repo.loans()).single;
    expect(saved.remaining, 0);
    expect(saved.isSettled, isTrue);
  });

  test('update direction, delete repayment and delete loan', () async {
    final repo = await openRepo();
    final loan = await repo.addLoan(
        person: 'Ana', direction: LoanDirection.lent, amount: 1000);
    await repo.addRepayment(loan.id, 500, '');
    await repo.updateLoan(loan.id,
        person: 'Ana P.', direction: LoanDirection.borrowed, note: 'x');

    await settle();
    var saved = (await repo.loans()).single;
    expect(saved.person, 'Ana P.');
    expect(saved.direction, LoanDirection.borrowed);

    await repo.deleteRepayment(loan.id, saved.repayments.single.id);
    await settle();
    saved = (await repo.loans()).single;
    expect(saved.repaid, 0);

    await repo.deleteLoan(loan.id);
    await settle();
    expect(await repo.loans(), isEmpty);
  });

  test('unknown stored direction falls back to lent', () {
    expect(LoanDirection.fromName('borrowed'), LoanDirection.borrowed);
    expect(LoanDirection.fromName('???'), LoanDirection.lent);
    expect(LoanDirection.fromName(null), LoanDirection.lent);
  });

  test('a loan in euros keeps its currency for repayments and edits',
      () async {
    final repo = await openRepo();
    final loan = await repo.addLoan(
      person: 'Banka',
      direction: LoanDirection.borrowed,
      amount: 500,
      currency: MoneyCurrency.eur,
    );
    await repo.addRepayment(loan.id, 200, '');
    await settle();
    var saved = (await repo.loans()).single;
    expect(saved.currency, MoneyCurrency.eur);
    expect(saved.remaining, 300);

    await repo.updateLoan(loan.id, currency: MoneyCurrency.rsd);
    await settle();
    saved = (await repo.loans()).single;
    expect(saved.currency, MoneyCurrency.rsd);
    expect(saved.repaid, 200);
  });

  test('loans recorded before currencies existed are in dinars', () {
    final loan = Loan.fromJson({
      'id': 'l',
      'person': 'Ana',
      'amount': 1000,
      'date': '2026-09-01T00:00:00.000',
    });
    expect(loan.currency, MoneyCurrency.rsd);
    expect(loan.toJson()['currency'], 'rsd');
    expect(MoneyCurrency.fromName('???'), MoneyCurrency.rsd);
  });

  test('totals are kept per currency and leave out settled loans', () {
    Loan loan(String id, LoanDirection d, MoneyCurrency c, double amount,
            {double repaid = 0}) =>
        Loan.fromJson({
          'id': id,
          'person': id,
          'direction': d.name,
          'currency': c.name,
          'amount': amount,
          'date': '2026-09-01T00:00:00.000',
          'repayments': [
            if (repaid > 0)
              {'id': '$id-r', 'amount': repaid, 'date': '2026-09-02T00:00:00.000'},
          ],
        });

    final totals = LoanTotals.of([
      loan('a', LoanDirection.lent, MoneyCurrency.rsd, 10000, repaid: 4000),
      loan('b', LoanDirection.lent, MoneyCurrency.rsd, 3000, repaid: 3000),
      loan('c', LoanDirection.borrowed, MoneyCurrency.eur, 500, repaid: 200),
    ]);

    expect(totals.map((t) => t.currency), [MoneyCurrency.rsd, MoneyCurrency.eur]);
    expect(totals[0].owedToMe, 6000);
    expect(totals[0].iOwe, 0);
    expect(totals[1].owedToMe, 0);
    expect(totals[1].net, -300);
    expect(LoanTotals.of([]), isEmpty);
  });
}
