import '../repositories/habit_stats_repository.dart';

class GetTodayHabitsSummaryUseCase {
  final HabitStatsRepository repository;

  GetTodayHabitsSummaryUseCase(this.repository);

  List<Map<String, dynamic>> call() {
    return repository.getTodayHabitsSummary();
  }
}
