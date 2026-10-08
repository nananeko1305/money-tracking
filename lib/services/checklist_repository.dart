import 'package:flutter/foundation.dart' show Listenable;

import '../models/checklist.dart';
import '../models/checklist_item.dart';
import 'app_data_encoder.dart';
import 'batch_commits.dart';
import 'id_generator.dart';
import 'user_collections.dart';
import 'user_session.dart';

/// CRUD for the signed-in account's checklists and their items. Checklists
/// are plans, independent of the budget and untouched when a month is closed.
/// Writes are not awaited (see [WriteErrors]).
class ChecklistRepository {
  ChecklistRepository(
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

  Future<List<Checklist>> checklists() async =>
      (await _session.live.ready()).checklists;

  Future<Checklist> addChecklist(String name) async {
    final list = Checklist(
      id: _ids.next(),
      name: name,
      createdAt: DateTime.now().toIso8601String(),
    );
    _write(_docs.checklists.doc(list.id).set(_encoder.checklist(list)));
    return list;
  }

  Future<void> renameChecklist(String id, String name) async =>
      _write(_docs.checklists.doc(id).update({'name': name}));

  /// Deletes the checklist together with its items.
  Future<void> deleteChecklist(String id) async {
    final items = _session.live.documents[UserCollections.checklistItemsName];
    commitInBatches(_docs, _session.writes, [
      (b) => b.delete(_docs.checklists.doc(id)),
      for (final doc in items)
        if (doc['listId'] == id)
          (b) => b.delete(_docs.checklistItems.doc(doc['id'] as String)),
    ]);
  }

  Future<ChecklistItem> addItem(
      String listId, String name, double amount) async {
    final item = ChecklistItem(
      id: _ids.next(),
      name: name,
      amount: amount,
      createdAt: DateTime.now().toIso8601String(),
    );
    _write(_docs.checklistItems
        .doc(item.id)
        .set(_encoder.checklistItem(item, listId: listId)));
    return item;
  }

  Future<void> updateItem(String itemId,
      {String? name, double? amount}) async {
    _write(_docs.checklistItems.doc(itemId).update({
      'name': ?name,
      'amount': ?amount,
    }));
  }

  Future<void> setItemDone(String itemId, bool done) async =>
      _write(_docs.checklistItems.doc(itemId).update({'done': done}));

  Future<void> deleteItem(String itemId) async =>
      _write(_docs.checklistItems.doc(itemId).delete());
}
