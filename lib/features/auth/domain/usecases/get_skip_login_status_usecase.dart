import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class GetSkipLoginStatusUseCase {
  final AuthRepository repository;
  GetSkipLoginStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.getSkipLoginStatus();
  }
}
