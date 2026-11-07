/// Monday, 00:00, of the week [date] falls in. Weeks run Monday to Sunday.
DateTime weekStart(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));

/// Days left until the next week begins: 7 on a Monday, 1 on a Sunday.
int daysUntilNextWeek(DateTime date) => DateTime.daysPerWeek + 1 - date.weekday;
