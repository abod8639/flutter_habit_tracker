import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class AddMultipleHabitsUseCase {
  final HabitRepository repository;

  AddMultipleHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> names) {
    return repository.addMultipleHabits(names);
  }
}
