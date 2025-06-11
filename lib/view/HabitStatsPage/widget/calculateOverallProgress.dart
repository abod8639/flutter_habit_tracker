List<double> calculateOverallProgress(
  Map<String, List<double>> habitProgression,
) {
  if (habitProgression.isEmpty) return [];

  final int days = habitProgression.values.first.length;
  List<double> overallProgress = List.filled(days, 0.0);

  for (var i = 0; i < days; i++) {
    int completedCount = 0;
    int totalHabits = 0;

    for (var habitData in habitProgression.values) {
      if (i < habitData.length) {
        if (habitData[i] > 0) completedCount++;
        totalHabits++;
      }
    }

    overallProgress[i] = totalHabits > 0 ? completedCount / totalHabits : 0.0;
  }

  return overallProgress;
}
