import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class GetLastSyncTimeUseCase {
  final SettingRepository repository;

  GetLastSyncTimeUseCase(this.repository);

  Future<Either<Failure, DateTime?>> call() async {
    return await repository.getLastSyncTime();
  }
}
