import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class ToggleHabitUseCase {
  final HabitRepository repository;

  ToggleHabitUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, bool isCompleted) {
    return repository.toggleHabit(id, isCompleted);
  }
}
