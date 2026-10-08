/// One thing to buy or do on a checklist: its name, the money planned for it
/// (0 when it is not known) and whether it is done.
class ChecklistItem {
  final String id;
  String name;
  double amount; // planned; 0 = not set
  bool done;
  final String createdAt; // ISO date string; keeps the list in entry order

  ChecklistItem({
    required this.id,
    required this.name,
    required this.createdAt,
    this.amount = 0,
    this.done = false,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: json['createdAt'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        done: (json['done'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'done': done,
        'createdAt': createdAt,
      };
}
