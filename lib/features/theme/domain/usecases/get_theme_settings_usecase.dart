import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/theme_entity.dart';
import '../repositories/theme_repository.dart';

class GetThemeSettingsUseCase {
  final ThemeRepository repository;

  GetThemeSettingsUseCase(this.repository);

  Future<Either<Failure, ThemeEntity>> call() async {
    return await repository.getThemeSettings();
  }
}
