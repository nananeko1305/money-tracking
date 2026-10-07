import 'package:flutter/foundation.dart' show Listenable;

import '../models/fixed_cost.dart';
import 'app_data_encoder.dart';
import 'id_generator.dart';
import 'user_collections.dart';
import 'user_session.dart';

/// CRUD for the signed-in account's fixed monthly costs. They are independent
/// of categories and untouched when a month is closed. Writes are not awaited
/// (see [WriteErrors]).
class FixedCostRepository {
  FixedCostRepository(
    this._session, {
    IdGenerator? ids,
    this._encoder = const AppDataEncoder(),
  }) : _ids = ids ?? IdGenerator();

  final UserSession _session;
  final IdGenerator _ids;
  final AppDataEncoder _encoder;

  UserCollections get _docs => _session.docs;

  void _write(Future<void> write) => _session.writes.track(write);

  /// Notifies whenever the account's data changes, on this phone or another.
  Listenable get changes => _session.live;

  Future<List<FixedCost>> fixedCosts() async =>
      (await _session.live.ready()).fixedCosts;

  Future<FixedCost> addFixedCost(String name, double amount) async {
    final cost = FixedCost(id: _ids.next(), name: name, amount: amount);
    // Creation time keeps new items after the existing ones.
    final order = DateTime.now().millisecondsSinceEpoch;
    _write(_docs.fixedCosts
        .doc(cost.id)
        .set(_encoder.fixedCost(cost, order: order)));
    return cost;
  }

  Future<void> updateFixedCost(String id,
      {String? name, double? amount}) async {
    _write(_docs.fixedCosts.doc(id).update({
      'name': ?name,
      'amount': ?amount,
    }));
  }

  Future<void> deleteFixedCost(String id) async =>
      _write(_docs.fixedCosts.doc(id).delete());
}
