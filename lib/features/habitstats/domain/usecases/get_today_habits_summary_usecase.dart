import '../repositories/habit_stats_repository.dart';

class GetTodayHabitsSummaryUseCase {
  final HabitStatsRepository repository;

  GetTodayHabitsSummaryUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return repository.getTodayHabitsSummary();
  }
}
