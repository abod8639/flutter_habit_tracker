import 'package:fl_chart/fl_chart.dart';
import '../repositories/habit_stats_repository.dart';

class GetIndividualHabitTrendsUseCase {
  final HabitStatsRepository repository;

  GetIndividualHabitTrendsUseCase(this.repository);

  Future<Map<String, List<FlSpot>>?> call(int days) async {
    return repository.getIndividualHabitTrends(days);
  }
}
