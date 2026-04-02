import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import '../models/date_time.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;
  final FirestoreService firestoreService;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.firestoreService,
  });

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async {
    try {
      final models = localDataSource.loadHabits();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHabit(String name) async {
    try {
      final models = localDataSource.loadHabits();
      final newModel = HabitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        index: models.length,
      );
      
      models.add(newModel);
      localDataSource.saveHabits(models);
      
      if (firestoreService.isUserLoggedIn) {
        await firestoreService.uploadHabits(models);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editHabit(String id, String newName) async {
    try {
      final models = localDataSource.loadHabits();
      final index = models.indexWhere((m) => m.id == id);
      
      if (index != -1) {
        final m = models[index];
        models[index] = HabitModel(
          id: m.id,
          name: newName,
          isCompleted: m.isCompleted,
          createdAt: m.createdAt,
          completedAt: m.completedAt,
          colorValue: m.colorValue,
          index: m.index,
          updatedAt: DateTime.now(),
        );
        
        localDataSource.saveHabits(models);
        
        if (firestoreService.isUserLoggedIn) {
          await firestoreService.uploadHabits(models);
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String id) async {
    try {
      final models = localDataSource.loadHabits();
      models.removeWhere((m) => m.id == id);
      
      localDataSource.saveHabits(models);
      localDataSource.addLocalTombstone(id);
      
      if (firestoreService.isUserLoggedIn) {
        await firestoreService.deleteHabit(id);
        await firestoreService.uploadHabits(models);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleHabit(String id, bool isCompleted) async {
    try {
      final models = localDataSource.loadHabits();
      final index = models.indexWhere((m) => m.id == id);
      
      if (index != -1) {
        final m = models[index];
        models[index] = HabitModel(
          id: m.id,
          name: m.name,
          isCompleted: isCompleted,
          createdAt: m.createdAt,
          completedAt: isCompleted ? DateTime.now() : null,
          colorValue: m.colorValue,
          index: m.index,
          updatedAt: DateTime.now(),
        );
        
        localDataSource.saveHabits(models);
        localDataSource.saveHabitCompletionHistory(m.name, isCompleted);
        
        final completedCount = models.where((m) => m.isCompleted).length;
        final completionRate = models.isEmpty ? 0.0 : completedCount / models.length;
        localDataSource.saveHabitStrength(todaysDateFormatted(), completionRate.toStringAsFixed(1));
        
        if (firestoreService.isUserLoggedIn) {
          await firestoreService.uploadHabits(models);
          await firestoreService.uploadHabitHistory(todaysDateFormatted(), completionRate.toStringAsFixed(1));
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderHabits(int oldIndex, int newIndex) async {
    try {
      final models = localDataSource.loadHabits();
      
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final model = models.removeAt(oldIndex);
      models.insert(newIndex, model);
      
      for (int i = 0; i < models.length; i++) {
        final m = models[i];
        models[i] = HabitModel(
          id: m.id,
          name: m.name,
          isCompleted: m.isCompleted,
          createdAt: m.createdAt,
          completedAt: m.completedAt,
          colorValue: m.colorValue,
          index: i,
          updatedAt: DateTime.now(),
        );
      }
      
      localDataSource.saveHabits(models);
      
      if (firestoreService.isUserLoggedIn) {
        await firestoreService.uploadHabits(models);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, int>>> getHeatmapData() async {
    try {
      final startDateStr = localDataSource.getStartDate();
      final startDate = createDateTimeObject(startDateStr);
      final daysInBetween = DateTime.now().difference(startDate).inDays;
      
      final Map<DateTime, int> heatmapData = {};
      
      for (int i = 0; i <= daysInBetween; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final yyyymmdd = convertDateTimeToString(currentDate);
        final strengthStr = localDataSource.getHabitStrength(yyyymmdd);
        final strength = double.tryParse(strengthStr ?? "0.0") ?? 0.0;
        
        heatmapData[DateTime(currentDate.year, currentDate.month, currentDate.day)] = (strength * 10).toInt();
      }
      
      return Right(heatmapData);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  bool isUserLoggedIn() {
    return firestoreService.isUserLoggedIn;
  }

  @override
  List<String> getLocalTombstones() {
    return localDataSource.getLocalTombstones();
  }

  @override
  void clearLocalTombstones() {
    localDataSource.clearLocalTombstones();
  }
}
