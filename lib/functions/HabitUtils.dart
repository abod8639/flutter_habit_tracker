// habit_utils.dart

bool shouldResetHabits(DateTime? lastResetDate) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  return lastResetDate == null || today.difference(lastResetDate).inDays >= 1;
}
