import '../repositories/habit_repository.dart';

class IsUserLoggedInUseCase {
  final HabitRepository repository;

  IsUserLoggedInUseCase(this.repository);

  bool call() {
    return repository.isUserLoggedIn();
  }
}
