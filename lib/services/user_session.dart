import 'package:cloud_firestore/cloud_firestore.dart';

import 'account_replacer.dart';
import 'live_user_data.dart';
import 'month_closer.dart';
import 'user_collections.dart';
import 'write_errors.dart';

/// Everything the signed-in account needs: where its documents live, the live
/// view of them, the month closer and the sink for write errors. Created when
/// the account signs in and disposed when it signs out, so nothing of one
/// account outlives it into the next.
class UserSession {
  UserSession({
    required FirebaseFirestore firestore,
    required this.uid,
    this.email,
    DateTime Function()? clock,
  }) : docs = UserCollections(firestore, uid) {
    live = LiveUserData(docs, clock: clock);
    closer = MonthCloser(live, docs, writes, clock: clock);
    replacer = AccountReplacer(live, docs, writes);
    live.addListener(closer.check);
    live.start();
  }

  final String uid;
  final String? email;
  final UserCollections docs;
  final WriteErrors writes = WriteErrors();
  late final LiveUserData live;
  late final MonthCloser closer;
  late final AccountReplacer replacer;

  void dispose() {
    live.removeListener(closer.check);
    live.dispose();
    writes.dispose();
  }
}
