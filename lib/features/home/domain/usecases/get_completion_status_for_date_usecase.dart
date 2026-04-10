import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class GetCompletionStatusForDateUseCase {
  final HabitRepository repository;

  GetCompletionStatusForDateUseCase(this.repository);

  Future<Either<Failure, Map<String, int>>> call(DateTime date) {
    return repository.getCompletionStatusForDate(date);
  }
}
