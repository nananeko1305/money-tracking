import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_data.dart';
import '../models/month_key.dart';
import 'app_data_encoder.dart';
import 'batch_commits.dart';
import 'live_user_data.dart';
import 'monthly_rollover.dart';
import 'user_collections.dart';
import 'write_errors.dart';

/// Closes the budget month once the calendar has moved past it, the cloud
/// counterpart of the old rollover on every read. [MonthlyRollover] builds the
/// report exactly as before; it is saved as reports/{month}, the profile moves
/// on to the new month, and the closed month's expenses are deleted (the
/// report keeps a copy). The report id is the month itself, so two phones
/// closing the same month write the same document instead of two.
class MonthCloser {
  MonthCloser(
    this._live,
    this._docs,
    this._writes, {
    this._encoder = const AppDataEncoder(),
    this._rollover = const MonthlyRollover(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const int keptReports = 12;

  final LiveUserData _live;
  final UserCollections _docs;
  final WriteErrors _writes;
  final AppDataEncoder _encoder;
  final MonthlyRollover _rollover;
  final DateTime Function() _clock;

  /// Repeated checks (every data change, every app resume) must do each
  /// piece of work once per session.
  bool _startedAccount = false;
  String? _closedMonth;

  void check() {
    final data = _live.data;
    if (data == null) return;
    final now = _clock();
    final current = monthKey(now);

    if (!_live.profileExists) {
      // A new account starts its first month, but only once the server has
      // confirmed there is no profile: an empty cache on a new phone proves
      // nothing.
      if (_live.confirmedByServer && !_startedAccount) {
        _startedAccount = true;
        _writes.track(_docs.profile.set(
          _encoder.profile(currentMonth: current, monthlyIncome: 0),
          SetOptions(merge: true),
        ));
      }
      return;
    }

    final open = _live.openMonth;
    if (open == current || _closedMonth == open) return;
    _closedMonth = open;
    _close(data, open, now);
  }

  void _close(AppData data, String open, DateTime now) {
    final ops = <BatchOp>[];
    final alreadyArchived = data.monthlyReports.any((r) => r.month == open);
    final copy = AppData.fromJson(data.toJson());
    if (!alreadyArchived && _rollover.apply(copy, now: now)) {
      final report = copy.monthlyReports.first;
      ops.add((b) => b.set(_docs.reports.doc(report.id), _encoder.report(report)));
      for (final old in data.monthlyReports.skip(keptReports - 1)) {
        ops.add((b) => b.delete(_docs.reports.doc(old.id)));
      }
    }
    ops.add((b) => b.set(
          _docs.profile,
          {'currentMonth': monthKey(now)},
          SetOptions(merge: true),
        ));
    for (final id in _live.documents.idsIn(UserCollections.expensesName)) {
      ops.add((b) => b.delete(_docs.expenses.doc(id)));
    }
    commitInBatches(_docs, _writes, ops);
  }
}
