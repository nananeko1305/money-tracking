import 'checklist_item.dart';
import 'money_currency.dart';

/// A named list of things to buy or do, such as "Market" or "Car parts", with
/// every planned amount in the list's [currency]. It is a plan, not spending:
/// it stays out of the budget and the reports, and nothing on it resets by
/// itself.
class Checklist {
  final String id;
  String name;
  final String createdAt; // ISO date string
  MoneyCurrency currency;
  List<ChecklistItem> items;

  Checklist({
    required this.id,
    required this.name,
    required this.createdAt,
    this.currency = MoneyCurrency.rsd,
    List<ChecklistItem>? items,
  }) : items = items ?? [];

  /// Money planned for every item.
  double get total => items.fold(0.0, (sum, i) => sum + i.amount);

  /// Money planned for the items not ticked off yet.
  double get left =>
      items.where((i) => !i.done).fold(0.0, (sum, i) => sum + i.amount);

  int get doneCount => items.where((i) => i.done).length;

  factory Checklist.fromJson(Map<String, dynamic> json) => Checklist(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: json['createdAt'] as String,
        currency: MoneyCurrency.fromName(json['currency'] as String?),
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
        'currency': currency.name,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
