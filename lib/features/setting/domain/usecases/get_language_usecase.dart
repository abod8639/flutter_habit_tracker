import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class GetLanguageUseCase {
  final SettingRepository repository;

  GetLanguageUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getLanguage();
  }
}
