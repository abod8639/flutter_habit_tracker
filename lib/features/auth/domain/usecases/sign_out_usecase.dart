import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
