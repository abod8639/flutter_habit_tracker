import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import 'package:hive/hive.dart';
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
    return addMultipleHabits([name]);
  }

  @override
  Future<Either<Failure, void>> addMultipleHabits(List<String> names) async {
    try {
      final models = localDataSource.loadHabits();
      final now = DateTime.now();
      
      for (final name in names) {
        if (name.trim().isEmpty) continue;
        
        final newModel = HabitModel(
          // Use microseconds and name hash to further reduce collision risk
          id: "${now.microsecondsSinceEpoch}_${name.hashCode}_${models.length}",
          name: name,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
          index: models.length,
        );
        models.add(newModel);
      }
      
      await localDataSource.saveHabits(models);
      
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
        
        await localDataSource.saveHabits(models);
        
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
      
      await localDataSource.saveHabits(models);
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
        
        await localDataSource.saveHabits(models);
        await localDataSource.saveHabitCompletionHistory(m.name, isCompleted);
        
        final completedCount = models.where((m) => m.isCompleted).length;
        final completionRate = models.isEmpty ? 0.0 : completedCount / models.length;
        await localDataSource.saveHabitStrength(todaysDateFormatted(), completionRate.toStringAsFixed(1));
        
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
      
      await localDataSource.saveHabits(models);
      
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
      // 1. Get historical data from local storage
      final rawHistory = await localDataSource.getAllHabitStrengths();
      
      // 2. Process large historical data set directly instead of using compute
      final heatmapData = _processHeatmapData(rawHistory);
      
      // 3. Recalculate TODAY's strength based on LIVE habits to ensure accuracy on startup
      final habits = localDataSource.loadHabits();
      if (habits.isNotEmpty) {
        final completedCount = habits.where((h) => h.isCompleted).length;
        final completionRate = completedCount / habits.length;
        int strength = (completionRate * 10).toInt();
        if (strength == 0 && completedCount > 0) strength = 1;
        
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        heatmapData[normalizedToday] = strength;
      }
      
      return Right(heatmapData);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateHabitOrder(List<String> ids) async {
    try {
      final models = localDataSource.loadHabits();
      final Map<String, HabitModel> modelMap = {for (var m in models) m.id: m};
      final List<HabitModel> reorderedModels = [];

      for (int i = 0; i < ids.length; i++) {
        final m = modelMap[ids[i]];
        if (m != null) {
          reorderedModels.add(HabitModel(
            id: m.id,
            name: m.name,
            isCompleted: m.isCompleted,
            createdAt: m.createdAt,
            completedAt: m.completedAt,
            colorValue: m.colorValue,
            index: i,
            updatedAt: DateTime.now(),
          ));
        }
      }

      await localDataSource.saveHabits(reorderedModels);

      if (firestoreService.isUserLoggedIn) {
        await firestoreService.uploadHabits(reorderedModels);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  bool isUserLoggedIn() {
    return firestoreService.isUserLoggedIn;
  }

  @override
  Future<Either<Failure, void>> updateHabitColor(String id, int colorValue) async {
    try {
      final models = localDataSource.loadHabits();
      final index = models.indexWhere((h) => h.id == id);
      if (index == -1) return Left(CacheFailure('Habit not found'));

      final m = models[index];
      models[index] = HabitModel(
        id: m.id,
        name: m.name,
        isCompleted: m.isCompleted,
        createdAt: m.createdAt,
        completedAt: m.completedAt,
        colorValue: colorValue,
        index: m.index,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveHabits(models);

      if (firestoreService.isUserLoggedIn) {
        await firestoreService.uploadHabits(models);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  List<String> getLocalTombstones() {
    return localDataSource.getLocalTombstones();
  }

  @override
  void clearLocalTombstones() {
    localDataSource.clearLocalTombstones();
  }

  @override
  Future<Either<Failure, DateTime?>> getLastResetDate() async {
    try {
      final box = Hive.box(HabitStorage.boxName);
      final dateStr = box.get(HabitStorage.lastResetDateKey);
      return Right(dateStr != null ? DateTime.parse(dateStr) : null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLastResetDate(DateTime date) async {
    try {
      final box = Hive.box(HabitStorage.boxName);
      await box.put(HabitStorage.lastResetDateKey, date.toIso8601String());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetHabitsCompletion() async {
    try {
      final habits = localDataSource.loadHabits();
      final resetHabits = habits.map((h) => HabitModel(
        id: h.id,
        name: h.name,
        isCompleted: false,
        createdAt: h.createdAt,
        completedAt: null,
        colorValue: h.colorValue,
        index: h.index,
        updatedAt: DateTime.now(),
      )).toList();
      
      await localDataSource.saveHabits(resetHabits);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementDayCount() async {
    try {
      final box = Hive.box(HabitStorage.boxName);
      int currentCount = box.get(HabitStorage.dayCountKey) ?? 1;
      await box.put(HabitStorage.dayCountKey, currentCount + 1);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveHabitCompletionToHistory(String habitName, bool isCompleted, DateTime date) async {
    try {
      final box = await _openMonthlyBoxForDate(date);
      final dateStr = convertDateTimeToString(date);
      final historyKey = "${habitName}_$dateStr";
      await box.put(historyKey, isCompleted);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // Helper to open monthly box
  Future<Box> _openMonthlyBoxForDate(DateTime date) async {
    final monthStr = convertDateTimeToString(date).substring(0, 6);
    final boxName = "${HabitStorage.boxName}_history_$monthStr";
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  @override
  Future<Either<Failure, Map<String, Map<DateTime, bool>>>> getHabitHistoryMap(int days) async {
    try {
      final result = await localDataSource.getHabitHistoryMap(days);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

// Top level function for compute - Must be outside the class
Map<DateTime, int> _processHeatmapData(Map<String, String> rawData) {
  final Map<DateTime, int> heatmapData = {};
  for (var entry in rawData.entries) {
    try {
      // Handle both cases: key is "YYYYMMDD" or "PREFIX_YYYYMMDD"
      String yyyymmdd = entry.key;
      if (yyyymmdd.contains('_')) {
        yyyymmdd = yyyymmdd.split('_').last;
      }
      
      if (yyyymmdd.length != 8) continue;
      
      final yyyy = int.parse(yyyymmdd.substring(0, 4));
      final mm = int.parse(yyyymmdd.substring(4, 6));
      final dd = int.parse(yyyymmdd.substring(6, 8));
      
      final date = DateTime(yyyy, mm, dd);
      final doubleStrength = double.tryParse(entry.value) ?? 0.0;
      final strength = (doubleStrength * 10).toInt();
      heatmapData[date] = strength;
    } catch (_) {
      // Skip invalid entries
    }
  }
  return heatmapData;
}
