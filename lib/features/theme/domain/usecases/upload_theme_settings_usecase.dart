import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/theme_entity.dart';
import '../repositories/theme_repository.dart';

class UploadThemeSettingsUseCase {
  final ThemeRepository repository;

  UploadThemeSettingsUseCase(this.repository);

  Future<Either<Failure, void>> call(ThemeEntity settings) async {
    return await repository.uploadThemeToCloud(settings);
  }
}
