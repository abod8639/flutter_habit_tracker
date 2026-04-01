import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;
  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, AuthEntity?>> call() async {
    return await repository.signInWithGoogle();
  }
}
