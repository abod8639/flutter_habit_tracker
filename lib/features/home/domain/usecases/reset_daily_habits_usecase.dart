import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/functions/habit_utils.dart';
import '../repositories/habit_repository.dart';

class ResetDailyHabitsUseCase {
  final HabitRepository repository;

  ResetDailyHabitsUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    final dateResult = await repository.getLastResetDate();
    
    return dateResult.fold(
      (failure) => Left(failure),
      (lastResetDate) async {
        if (shouldResetHabits(lastResetDate)) {
          // 1. Get current habits to save to history
          final habitsResult = await repository.getHabits();
          
          return await habitsResult.fold(
            (failure) => Left(failure),
            (habits) async {
              final yesterday = DateTime.now().subtract(const Duration(days: 1));
              
              // 2. Save each habit's state to history
              for (var habit in habits) {
                await repository.saveHabitCompletionToHistory(habit.name, habit.isCompleted, yesterday);
              }

              // 3. Reset completion status
              final resetResult = await repository.resetHabitsCompletion();
              if (resetResult.isLeft()) return resetResult;

              // 4. Increment day count
              final incrementResult = await repository.incrementDayCount();
              if (incrementResult.isLeft()) return incrementResult;

              // 5. Update last reset date
              return await repository.saveLastResetDate(DateTime.now());
            },
          );
        }
        return const Right(null);
      },
    );
  }
}
