import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteHabit(id);
  }
}
