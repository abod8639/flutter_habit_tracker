import 'package:fl_chart/fl_chart.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/habit_stats_entity.dart';

class HabitStatsLocalDataSource {
  final Box myBox;
  final HabitRepository habitRepository;

  HabitStatsLocalDataSource({
    required this.myBox,
    required this.habitRepository,
  });

  Future<HabitStatsEntity> getOverallStats() async {
    final result = await habitRepository.getHabits();
    return result.fold(
      (failure) => const HabitStatsEntity(
        totalHabits: 0,
        completedHabits: 0,
        completionRate: 0,
        streak: 0,
      ),
      (habits) {
        final int totalHabits = habits.length;
        final int completedHabits = habits.where((h) => h.isCompleted).length;
        final double completionRate = totalHabits > 0
            ? (completedHabits / totalHabits) * 100
            : 0;

        final int streak = myBox.get(HabitStorage.dayCountKey) ?? 1;

        return HabitStatsEntity(
          totalHabits: totalHabits,
          completedHabits: completedHabits,
          completionRate: completionRate,
          streak: streak,
        );
      },
    );
  }

  Future<List<FlSpot>> getOverallTrendData(int days) async {
    final habitsResult = await habitRepository.getHabits();
    return habitsResult.fold(
      (failure) => [const FlSpot(0, 0)],
      (habits) async {
        if (habits.isEmpty) return [const FlSpot(0, 0)];

        final heatmapResult = await habitRepository.getHeatmapData();
        return heatmapResult.fold(
          (failure) => [const FlSpot(0, 0)],
          (heatmapData) {
            final now = DateTime.now();
            final List<FlSpot> trendSpots = [];

            for (int i = 0; i < days; i++) {
              final date = now.subtract(Duration(days: days - 1 - i));
              final normalizedDate = DateTime(date.year, date.month, date.day);

              final int? completionValue = heatmapData[normalizedDate];
              final double percentage = completionValue != null
                  ? completionValue / 10.0
                  : 0.0;

              trendSpots.add(FlSpot(i.toDouble(), percentage.clamp(0.0, 1.0)));
            }
            return trendSpots;
          },
        );
      },
    );
  }

  Future<Map<String, List<FlSpot>>> getIndividualHabitTrends(
    int days,
    Map<String, Map<DateTime, bool>> historyMap,
  ) async {
    final habitsResult = await habitRepository.getHabits();
    return habitsResult.fold(
      (failure) => {},
      (habitsList) {
        if (habitsList.isEmpty) return {};

        final Map<String, List<FlSpot>> habitProgressMap = {};
        final now = DateTime.now();

        for (var habit in habitsList) {
          final String habitName = habit.name;
          final List<FlSpot> spots = [];

          for (int i = 0; i < days; i++) {
            final date = now.subtract(Duration(days: days - 1 - i));
            final normalizedDate = DateTime(date.year, date.month, date.day);

            final bool? completed = historyMap[habitName]?[normalizedDate];

            if (i == days - 1 && completed == null) {
              spots.add(FlSpot(i.toDouble(), habit.isCompleted ? 1.0 : 0.0));
            } else {
              spots.add(FlSpot(i.toDouble(), completed == true ? 1.0 : 0.00));
            }
          }
          habitProgressMap[habitName] = spots;
        }
        return habitProgressMap;
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTodayHabitsSummary() async {
    final result = await habitRepository.getHabits();
    return result.fold(
      (failure) => [],
      (habitsList) {
        return List.generate(habitsList.length, (index) {
          final habit = habitsList[index];
          return {
            'id': habit.id,
            'habit': habit.name,
            'completed': habit.isCompleted,
            'createdAt': habit.createdAt,
          };
        });
      },
    );
  }
}

