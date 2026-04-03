import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class ClearAllDataUseCase {
  final SettingRepository repository;

  ClearAllDataUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearAllData();
  }
}
