import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../../domain/repositories/habit_stats_repository.dart';
import '../datasources/habit_stats_local_datasource.dart';

class HabitStatsRepositoryImpl implements HabitStatsRepository {
  final HabitStatsLocalDataSource localDataSource;
  final Map<String, Map<DateTime, bool>> Function() getHistoryMap;

  HabitStatsRepositoryImpl({
    required this.localDataSource,
    required this.getHistoryMap,
  });

  @override
  HabitStatsEntity getOverallStats() {
    return localDataSource.getOverallStats();
  }

  @override
  List<FlSpot> getOverallTrendData(int days) {
    return localDataSource.getOverallTrendData(days);
  }

  @override
  Map<String, List<FlSpot>> getIndividualHabitTrends(int days) {
    final historyMap = getHistoryMap();
    return localDataSource.getIndividualHabitTrends(days, historyMap);
  }

  @override
  List<Map<String, dynamic>> getTodayHabitsSummary() {
    return localDataSource.getTodayHabitsSummary();
  }
}
