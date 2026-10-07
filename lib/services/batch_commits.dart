import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_collections.dart';
import 'write_errors.dart';

/// One write to add to a batch.
typedef BatchOp = void Function(WriteBatch batch);

/// Firestore caps a batch at 500 writes.
const int _batchLimit = 450;

/// Applies [ops] in as many batches as the cap needs, each commit handed to
/// [writes]. Batches are atomic on their own, not across each other, so ops
/// must be safe to land partially (sets and deletes by id are).
void commitInBatches(
  UserCollections docs,
  WriteErrors writes,
  List<BatchOp> ops,
) {
  for (var start = 0; start < ops.length; start += _batchLimit) {
    final batch = docs.batch();
    for (final op in ops.skip(start).take(_batchLimit)) {
      op(batch);
    }
    writes.track(batch.commit());
  }
}
