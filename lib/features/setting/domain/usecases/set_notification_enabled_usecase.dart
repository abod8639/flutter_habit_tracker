import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class SetNotificationEnabledUseCase {
  final SettingRepository repository;

  SetNotificationEnabledUseCase(this.repository);

  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.setNotificationEnabled(enabled);
  }
}
