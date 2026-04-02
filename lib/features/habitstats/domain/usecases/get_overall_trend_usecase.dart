import 'package:fl_chart/fl_chart.dart';
import '../repositories/habit_stats_repository.dart';

class GetOverallTrendUseCase {
  final HabitStatsRepository repository;

  GetOverallTrendUseCase(this.repository);

  Future<List<FlSpot>> call(int days) async {
    return repository.getOverallTrendData(days);
  }
}
