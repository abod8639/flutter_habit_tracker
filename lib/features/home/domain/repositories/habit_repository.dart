import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Future<Either<Failure, List<HabitEntity>>> getHabits();
  Future<Either<Failure, void>> addHabit(String name);
  Future<Either<Failure, void>> editHabit(String id, String newName);
  Future<Either<Failure, void>> deleteHabit(String id);
  Future<Either<Failure, void>> toggleHabit(String id, bool isCompleted);
  Future<Either<Failure, void>> reorderHabits(int oldIndex, int newIndex);
  Future<Either<Failure, Map<DateTime, int>>> getHeatmapData();
  bool isUserLoggedIn();
  List<String> getLocalTombstones();
  void clearLocalTombstones();
}
