import 'package:habit_tracker/core/services/firestore_service.dart';
import '../models/theme_model.dart';

abstract class ThemeRemoteDataSource {
  Future<ThemeModel?> syncWithCloud();
  Future<void> uploadThemeToCloud(ThemeModel settings);
}

class ThemeRemoteDataSourceImpl implements ThemeRemoteDataSource {
  final FirestoreService firestoreService;

  ThemeRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<ThemeModel?> syncWithCloud() async {
    final cloudTheme = await firestoreService.downloadTheme();
    if (cloudTheme != null) {
      return ThemeModel.fromJson(cloudTheme);
    }
    return null;
  }

  @override
  Future<void> uploadThemeToCloud(ThemeModel settings) async {
    await firestoreService.uploadTheme(
      settings.themeName,
      settings.themeMode,
      settings.useCustomBackground,
      settings.customBackgroundColor,
    );
  }
}
