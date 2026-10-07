/// A calendar month as "YYYY-MM": the id of a monthly report and the budget
/// month an expense belongs to.
String monthKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

/// The first day of the month a [monthKey] names, or null when [key] is not a
/// "YYYY-MM" month.
DateTime? monthStart(String key) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(key);
  if (match == null) return null;
  final month = int.parse(match.group(2)!);
  if (month < 1 || month > 12) return null;
  return DateTime(int.parse(match.group(1)!), month);
}
