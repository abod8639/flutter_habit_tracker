import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class AddHabitUseCase {
  final HabitRepository repository;

  AddHabitUseCase(this.repository);

  Future<Either<Failure, void>> call(String name) {
    return repository.addHabit(name);
  }
}
