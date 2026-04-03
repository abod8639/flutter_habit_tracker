import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/services/firestore_service.dart';
import '../../domain/repositories/setting_repository.dart';
import '../datasources/setting_local_datasource.dart';
import '../datasources/setting_remote_datasource.dart';

class SettingRepositoryImpl implements SettingRepository {
  final SettingLocalDataSource localDataSource;
  final SettingRemoteDataSource remoteDataSource;

  SettingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> getLanguage() async {
    try {
      final lang = await localDataSource.getLanguage();
      return Right(lang);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLanguage(String languageCode) async {
    try {
      await localDataSource.saveLanguage(languageCode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isNotificationEnabled() async {
    try {
      return Right(localDataSource.isNotificationEnabled());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationEnabled(bool enabled) async {
    try {
      await localDataSource.setNotificationEnabled(enabled);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TimeOfDay?>> getNotificationTime() async {
    try {
      return Right(localDataSource.getNotificationTime());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationTime(TimeOfDay time) async {
    try {
      await localDataSource.setNotificationTime(time);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitModel>>> syncHabits(List<HabitModel> localHabits, {List<String>? localTombstones}) async {
    try {
      final mergedHabits = await remoteDataSource.syncHabits(localHabits, localTombstones: localTombstones);
      return Right(mergedHabits);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final time = await remoteDataSource.getLastSyncTime();
      return Right(time);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      // 1. Clear Remote Data if logged in
      final firestoreService = FirestoreService();
      if (firestoreService.isUserLoggedIn) {
        await firestoreService.deleteAllUserData();
      }
      
      // 2. Clear Local Data
      await localDataSource.clearAllData();
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
