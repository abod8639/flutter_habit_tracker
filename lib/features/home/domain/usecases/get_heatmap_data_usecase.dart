import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class GetHeatmapDataUseCase {
  final HabitRepository repository;

  GetHeatmapDataUseCase(this.repository);

  Future<Either<Failure, Map<DateTime, int>>> call() {
    return repository.getHeatmapData();
  }
}
