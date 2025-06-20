import 'package:habit_tracker/main.dart';
import 'package:habit_tracker/services/readHiveData.dart';

Future<void> syncHiveToSupabase() async {
  final rows = await readHiveData();
  const batchSize = 250;
  for (var i = 0; i < rows.length; i += batchSize) {
    final chunk = rows.sublist(i, (i + batchSize).clamp(0, rows.length));
    final response =
        await supabase
            .from('my_table')
            .upsert(chunk)
            // استخدم insert() إذا كنت متأكدًا من عدم وجود صفوف مسبقًا
            // .onConflict('id')     // يحلّ التعارض على المفتاح الأساسي
            .select(); // يعيد الصفوف المُدخلة للتأكيد
    if (response != null) throw response!;
  }
}
