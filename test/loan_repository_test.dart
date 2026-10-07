import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/models/loan_direction.dart';
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
}
