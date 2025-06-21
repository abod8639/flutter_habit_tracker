// import 'package:supabase_flutter/supabase_flutter.dart';

// final supabase = Supabase.instance.client;

// /// دالة ترفع العادات إلى Supabase
// Future<void> uploadHabitsToSupabase({
//   required List<Map<String, dynamic>> habits,
// }) async {
//   if (habits.isEmpty) return;

//   const chunkSize = 200; // لتفادي مشاكل الحجم
//   for (int i = 0; i < habits.length; i += chunkSize) {
//     final chunk = habits.sublist(i, (i + chunkSize).clamp(0, habits.length));

//     final response =
//         await supabase
//             .from('habits')
//             .upsert(chunk) // upsert بدل insert لتفادي التكرار حسب id
//             // .onConflict('id') // التعارض على المفتاح الأساسي
//             .select();

//     // if (response != null) {
//     //   throw Exception('Upload failed: ${response.message}');
//     // }
//   }
// }
