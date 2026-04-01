import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class SetNotificationTimeUseCase {
  final SettingRepository repository;

  SetNotificationTimeUseCase(this.repository);

  Future<Either<Failure, void>> call(TimeOfDay time) async {
    return await repository.setNotificationTime(time);
  }
}
