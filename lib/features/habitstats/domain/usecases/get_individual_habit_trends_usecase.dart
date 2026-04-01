import 'package:fl_chart/fl_chart.dart';
import '../repositories/habit_stats_repository.dart';

class GetIndividualHabitTrendsUseCase {
  final HabitStatsRepository repository;

  GetIndividualHabitTrendsUseCase(this.repository);

  Map<String, List<FlSpot>> call(int days) {
    return repository.getIndividualHabitTrends(days);
  }
}
