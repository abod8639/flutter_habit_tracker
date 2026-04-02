import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/auth/data/datasources/auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SettingsStorage _settingsStorage;

  AuthLocalDataSourceImpl(this._settingsStorage);

  @override
  Future<void> setSkipLogin(bool skipped) async {
    await _settingsStorage.setSkippedLogin(skipped);
  }

  @override
  Future<bool> getSkipLoginStatus() async {
    return _settingsStorage.hasSkippedLogin;
  }
}
