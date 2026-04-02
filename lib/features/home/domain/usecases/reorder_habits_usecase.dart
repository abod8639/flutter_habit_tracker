import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class ReorderHabitsUseCase {
  final HabitRepository repository;

  ReorderHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call(int oldIndex, int newIndex) {
    return repository.reorderHabits(oldIndex, newIndex);
  }
}
