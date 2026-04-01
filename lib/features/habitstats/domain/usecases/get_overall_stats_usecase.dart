import '../entities/habit_stats_entity.dart';
import '../repositories/habit_stats_repository.dart';

class GetOverallStatsUseCase {
  final HabitStatsRepository repository;

  GetOverallStatsUseCase(this.repository);

  HabitStatsEntity call() {
    return repository.getOverallStats();
  }
}
