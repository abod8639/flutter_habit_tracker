import 'package:fl_chart/fl_chart.dart';
import '../repositories/habit_stats_repository.dart';

class GetOverallTrendUseCase {
  final HabitStatsRepository repository;

  GetOverallTrendUseCase(this.repository);

  List<FlSpot> call(int days) {
    return repository.getOverallTrendData(days);
  }
}
