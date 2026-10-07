import '../models/app_data.dart';
import 'app_data_encoder.dart';
import 'batch_commits.dart';
import 'live_user_data.dart';
import 'user_collections.dart';
import 'write_errors.dart';

/// Replaces everything an account holds with a given [AppData]: importing a
/// backup file, or moving the data kept on the phone before accounts existed.
/// Documents missing from the new data are deleted, the rest overwritten.
class AccountReplacer {
  AccountReplacer(
    this._live,
    this._docs,
    this._writes, {
    this._encoder = const AppDataEncoder(),
  });

  final LiveUserData _live;
  final UserCollections _docs;
  final WriteErrors _writes;
  final AppDataEncoder _encoder;

  /// Call once the live view is ready, so it knows what to delete.
  void replaceWith(AppData data) {
    final next = _encoder.encode(data);
    final current = _live.documents;
    final ops = <BatchOp>[(b) => b.set(_docs.profile, next.profile!)];
    for (final name in UserCollections.names) {
      final keep = next.idsIn(name);
      for (final id in current.idsIn(name)) {
        if (!keep.contains(id)) {
          ops.add((b) => b.delete(_docs.collection(name).doc(id)));
        }
      }
      for (final doc in next[name]) {
        ops.add((b) => b.set(_docs.collection(name).doc(doc['id'] as String), doc));
      }
    }
    commitInBatches(_docs, _writes, ops);
  }
}
