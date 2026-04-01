import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateUseCase {
  final AuthRepository repository;
  GetAuthStateUseCase(this.repository);

  Stream<AuthEntity?> call() {
    return repository.authStateChanges;
  }
}
