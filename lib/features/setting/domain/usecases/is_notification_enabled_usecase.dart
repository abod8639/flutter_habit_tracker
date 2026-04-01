import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class IsNotificationEnabledUseCase {
  final SettingRepository repository;

  IsNotificationEnabledUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isNotificationEnabled();
  }
}
