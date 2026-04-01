import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/theme_entity.dart';
import '../repositories/theme_repository.dart';

class SaveThemeSettingsUseCase {
  final ThemeRepository repository;

  SaveThemeSettingsUseCase(this.repository);

  Future<Either<Failure, void>> call(ThemeEntity settings) async {
    return await repository.saveThemeSettings(settings);
  }
}
