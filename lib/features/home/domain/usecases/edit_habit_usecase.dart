import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class EditHabitUseCase {
  final HabitRepository repository;

  EditHabitUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String newName) {
    return repository.editHabit(id, newName);
  }
}
