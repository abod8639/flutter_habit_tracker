import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class GetHabitsUseCase {
  final HabitRepository repository;

  GetHabitsUseCase(this.repository);

  Future<Either<Failure, List<HabitEntity>>> call() {
    return repository.getHabits();
  }
}
