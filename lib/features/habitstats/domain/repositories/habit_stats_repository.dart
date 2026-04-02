import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/habit_stats_entity.dart';

abstract class HabitStatsRepository {
  Future<HabitStatsEntity> getOverallStats();
  Future<List<FlSpot>> getOverallTrendData(int days);
  Future<Map<String, List<FlSpot>>?> getIndividualHabitTrends(int days);
  Future<List<Map<String, dynamic>>> getTodayHabitsSummary();
}
