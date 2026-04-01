import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/setting_repository.dart';

class SaveLanguageUseCase {
  final SettingRepository repository;

  SaveLanguageUseCase(this.repository);

  Future<Either<Failure, void>> call(String languageCode) async {
    return await repository.saveLanguage(languageCode);
  }
}
