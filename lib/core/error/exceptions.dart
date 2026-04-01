class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String? message;
  const NetworkException([this.message]);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
