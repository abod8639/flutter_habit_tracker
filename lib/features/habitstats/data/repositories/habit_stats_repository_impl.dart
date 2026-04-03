import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../../domain/repositories/habit_stats_repository.dart';
import '../datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';

class HabitStatsRepositoryImpl implements HabitStatsRepository {
  final HabitStatsLocalDataSource localDataSource;
  final HabitRepository habitRepository;

  HabitStatsRepositoryImpl({
    required this.localDataSource,
    required this.habitRepository,
  });

  @override
  Future<HabitStatsEntity> getOverallStats() async {
    return localDataSource.getOverallStats();
  }

  @override
  Future<List<FlSpot>> getOverallTrendData(int days) async {
    return localDataSource.getOverallTrendData(days);
  }

  @override
  Future<Map<String, List<FlSpot>>?> getIndividualHabitTrends(int days) async {
    return await localDataSource.getIndividualHabitTrends(days);
  }

  @override
  Future<List<Map<String, dynamic>>> getTodayHabitsSummary() async {
    return localDataSource.getTodayHabitsSummary();
  }
}
