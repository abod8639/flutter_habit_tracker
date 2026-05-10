import '../repositories/habit_repository.dart';

class GetStartDateUseCase {
  final HabitRepository repository;

  GetStartDateUseCase(this.repository);

  String call() {
    return repository.getStartDate();
  }
}
