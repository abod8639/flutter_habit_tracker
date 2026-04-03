import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';

class UpdateHabitColorUseCase {
  final HabitRepository repository;

  UpdateHabitColorUseCase({required this.repository});

  Future<Either<Failure, void>> call(String id, int colorValue) async {
    return await repository.updateHabitColor(id, colorValue);
  }
}
