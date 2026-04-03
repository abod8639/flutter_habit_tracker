import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';

class UpdateHabitOrderUseCase {
  final HabitRepository repository;

  UpdateHabitOrderUseCase({required this.repository});

  Future<Either<Failure, void>> call(List<String> ids) async {
    return await repository.updateHabitOrder(ids);
  }
}
