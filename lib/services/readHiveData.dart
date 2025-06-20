import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:hive/hive.dart';

Future<List<Map<String, dynamic>>> readHiveData() async {
  final box = await Hive.openBox<HabitModel>('my_model');
  // تحويل كل كائن إلى Map حسب الحقول المطلوبة في قاعدة Supabase
  return box.values
      .map(
        (model) => {
          'id': model.id,
          'name': model.name,
          'isCompleted': model.isCompleted,
          'createdAt': model.createdAt,
          'created_at': model.createdAt.toIso8601String(),
          'completed_at': model.completedAt?.toIso8601String(),
          // ...
        },
      )
      .toList();
}
