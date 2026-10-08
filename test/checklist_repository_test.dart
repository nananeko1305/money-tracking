import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:budget_tracker/services/budget_repository.dart';
import 'package:budget_tracker/services/checklist_repository.dart';
import 'package:budget_tracker/services/user_collections.dart';

import 'fake_account.dart';

void main() {
  test('lists keep their items, totals and ticks', () async {
    final repo = ChecklistRepository(await openFakeSession());
    final market = await repo.addChecklist('Market');
    final milk = await repo.addItem(market.id, 'Mleko', 200);
    await repo.addItem(market.id, 'Hleb', 80);
    await repo.addItem(market.id, 'Kesa', 0); // price not known yet
    await settle();

    var list = (await repo.checklists()).single;
    expect(list.items.map((i) => i.name), ['Mleko', 'Hleb', 'Kesa']);
    expect(list.total, 280);
    expect(list.left, 280);

    await repo.setItemDone(milk.id, true);
    await settle();
    list = (await repo.checklists()).single;
    expect(list.doneCount, 1);
    expect(list.left, 80);

    await repo.updateItem(milk.id, name: 'Mleko 2l', amount: 250);
    await repo.renameChecklist(market.id, 'Maxi');
    await settle();
    list = (await repo.checklists()).single;
    expect(list.name, 'Maxi');
    expect(list.items.first.name, 'Mleko 2l');
    expect(list.items.first.done, isTrue);
    expect(list.total, 330);
  });

  test('deleting an item or a whole list', () async {
    final session = await openFakeSession();
    final repo = ChecklistRepository(session);
    final trip = await repo.addChecklist('More');
    final cream = await repo.addItem(trip.id, 'Krema', 900);
    await repo.addItem(trip.id, 'Peškir', 1500);
    await repo.addChecklist('Delovi');
    await settle();

    await repo.deleteItem(cream.id);
    await settle();
    expect((await repo.checklists()).first.items.single.name, 'Peškir');

    await repo.deleteChecklist(trip.id);
    await settle();
    expect((await repo.checklists()).single.name, 'Delovi');
    final items = await session.docs
        .collection(UserCollections.checklistItemsName)
        .get();
    expect(items.docs, isEmpty);
  });

  test('closing the month leaves the lists alone', () async {
    var now = DateTime(2026, 9, 15);
    final session = await openFakeSession(clock: () => now);
    final repo = ChecklistRepository(session);
    await BudgetRepository(session).addCategory('Hrana', 1000);
    final list = await repo.addChecklist('Market');
    final item = await repo.addItem(list.id, 'Mleko', 200);
    await repo.setItemDone(item.id, true);
    await settle();

    now = DateTime(2026, 10, 1);
    session.closer.check();
    await settle();

    final kept = (await repo.checklists()).single;
    expect(kept.items.single.done, isTrue);
  });

  test('lists travel with backups; older backups have none', () async {
    final source = await openFakeSession();
    final repo = ChecklistRepository(source);
    final list = await repo.addChecklist('Šoping');
    await repo.addItem(list.id, 'Patike', 9000);
    await settle();
    final exported = await BudgetRepository(source).exportJson();

    final target = await openFakeSession();
    expect(await BudgetRepository(target).importJson(exported), isTrue);
    await settle();
    final restored = (await ChecklistRepository(target).checklists()).single;
    expect(restored.name, 'Šoping');
    expect(restored.items.single.amount, 9000);

    final old = await openFakeSession();
    await BudgetRepository(old).importJson(jsonEncode({
      'currentCategories': [],
      'monthlyReports': [],
      'lastResetDate': '2026-09-01T00:00:00.000',
    }));
    await settle();
    expect(await ChecklistRepository(old).checklists(), isEmpty);
  });
}
