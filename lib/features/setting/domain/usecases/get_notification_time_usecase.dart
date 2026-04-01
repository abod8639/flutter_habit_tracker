import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class GetNotificationTimeUseCase {
  final SettingRepository repository;

  GetNotificationTimeUseCase(this.repository);

  Future<Either<Failure, TimeOfDay?>> call() async {
    return await repository.getNotificationTime();
  }
}
