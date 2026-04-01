import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SetSkipLoginUseCase {
  final AuthRepository repository;
  SetSkipLoginUseCase(this.repository);

  Future<Either<Failure, void>> call(bool skipped) async {
    return await repository.setSkipLogin(skipped);
  }
}
