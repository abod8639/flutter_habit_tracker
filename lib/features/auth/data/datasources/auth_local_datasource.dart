abstract class AuthLocalDataSource {
  Future<void> setSkipLogin(bool skipped);
  Future<bool> getSkipLoginStatus();
}
