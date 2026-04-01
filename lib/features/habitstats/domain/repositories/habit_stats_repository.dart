import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/habit_stats_entity.dart';

abstract class HabitStatsRepository {
  HabitStatsEntity getOverallStats();
  List<FlSpot> getOverallTrendData(int days);
  Map<String, List<FlSpot>> getIndividualHabitTrends(int days);
  List<Map<String, dynamic>> getTodayHabitsSummary();
}
