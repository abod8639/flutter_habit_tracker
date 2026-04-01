import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/firestore_service.dart';

abstract class SettingRemoteDataSource {
  Future<List<HabitModel>> syncHabits(List<HabitModel> localHabits, {List<String>? localTombstones});
  Future<DateTime?> getLastSyncTime();
}

class SettingRemoteDataSourceImpl implements SettingRemoteDataSource {
  final FirestoreService _firestoreService;

  SettingRemoteDataSourceImpl(this._firestoreService);

  @override
  Future<List<HabitModel>> syncHabits(List<HabitModel> localHabits, {List<String>? localTombstones}) async {
    return await _firestoreService.syncHabits(localHabits, localTombstones: localTombstones ?? []);
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return await _firestoreService.getLastSyncTime();
  }
}
