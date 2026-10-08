import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/amount_input.dart';
import '../models/loan.dart';
import '../models/loan_direction.dart';
import '../models/money_currency.dart';
import '../theme.dart';

/// The values entered in the loan add / edit form.
class LoanFormResult {
  final LoanDirection direction;
  final String person;
  final double amount;
  final MoneyCurrency currency;
  final String note;
  const LoanFormResult(
      this.direction, this.person, this.amount, this.currency, this.note);
}

/// Shows the add / edit loan dialog. Returns the entered values, or null if it
/// was dismissed. Pass [existing] to prefill the fields for editing.
Future<LoanFormResult?> showLoanFormDialog(
  BuildContext context, {
  Loan? existing,
}) {
  final t = AppScope.of(context).strings;
  final pal = palette(context);
  final personController = TextEditingController(text: existing?.person ?? '');
  final amountController = TextEditingController(
      text: existing != null ? amountInputText(existing.amount) : '');
  final noteController = TextEditingController(text: existing?.note ?? '');
  var direction = existing?.direction ?? LoanDirection.lent;
  var currency = existing?.currency ?? MoneyCurrency.rsd;
  final segmentStyle = SegmentedButton.styleFrom(
    selectedBackgroundColor: pal.green,
    selectedForegroundColor: Colors.white,
  );

  return showDialog<LoanFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(existing == null ? t.newLoan : t.editLoan),
      content: SingleChildScrollView(
        // One builder for the whole form: the amount's currency suffix
        // follows the currency selector.
        child: StatefulBuilder(
          builder: (_, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<LoanDirection>(
                  showSelectedIcon: false,
                  style: segmentStyle,
                  segments: [
                    ButtonSegment(
                        value: LoanDirection.lent, label: Text(t.owedToMe)),
                    ButtonSegment(
                        value: LoanDirection.borrowed, label: Text(t.iOwe)),
                  ],
                  selected: {direction},
                  onSelectionChanged: (s) =>
                      setState(() => direction = s.first),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: personController,
                autofocus: existing == null,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: t.loanPerson,
                  hintText: t.loanPersonHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: t.amountHint,
                  hintText: t.loanAmountHint,
                  suffixText: t.currencySymbol(currency),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<MoneyCurrency>(
                  showSelectedIcon: false,
                  style: segmentStyle,
                  segments: [
                    ButtonSegment(
                        value: MoneyCurrency.rsd, label: Text(t.dinars)),
                    ButtonSegment(
                        value: MoneyCurrency.eur, label: Text(t.euros)),
                  ],
                  selected: {currency},
                  onSelectionChanged: (s) =>
                      setState(() => currency = s.first),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: t.loanNoteHint),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            final person = personController.text.trim();
            final amount = parseAmountInput(amountController.text);
            if (person.isEmpty || amount == null || amount <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(t.invalidLoan)),
              );
              return;
            }
            Navigator.pop(
                ctx,
                LoanFormResult(
                    direction, person, amount, currency, noteController.text));
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}
