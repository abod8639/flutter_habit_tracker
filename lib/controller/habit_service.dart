// import 'package:get/get.dart';
// import 'package:habit_tracker/controller/supabase_service.dart';
// import 'package:habit_tracker/models/habit_model.dart';
// // import 'package:habit_tracker/services/supabase_service.dart';


// class HabitService extends GetxService {
//   static HabitService get to => Get.find();
//   final SupabaseService _supabaseService = SupabaseService.to;
  
//   // الحصول على كل العادات للمستخدم الحالي
// Future<List<Habit>> getHabits() async {
//   final userId = _supabaseService.currentUserId;
//   if (userId == null) return [];

//   final List<dynamic> response = await _supabaseService.client
//       .from('habits')
//       .select()
//       .eq('user_id', userId)
//       .order('created_at');

//   return response.map((item) => Habit.fromJson(item)).toList();
// }

  
//   // إضافة عادة جديدة
// Future<Habit> addHabit(String name) async {
//   final userId = _supabaseService.currentUserId;
//   if (userId == null) throw 'يجب تسجيل الدخول أولاً';

//   final habit = Habit(
//     userId: userId,
//     name: name,
//   );

//   final List<dynamic> response = await _supabaseService.client
//       .from('habits')
//       .insert(habit.toJson())
//       .select();

//   return Habit.fromJson(response.first);
// }

  
//   // تحديث حالة عادة
//   Future<void> toggleHabit(Habit habit) async {
//     if (habit.id == null) throw 'معرف العادة غير صحيح';
    
//     await _supabaseService.client
//         .from('habits')
//         .update({'completed': !habit.completed})
//         .eq('id', habit.id.toString() );
//   }
  
//   // تعديل اسم عادة
//   Future<void> updateHabitName(String habitId, String newName) async {
//     await _supabaseService.client
//         .from('habits')
//         .update({'name': newName})
//         .eq('id', habitId);
//   }
  
//   // حذف عادة
//   Future<void> deleteHabit(String habitId) async {
//     await _supabaseService.client
//         .from('habits')
//         .delete()
//         .eq('id', habitId);
//   }
  
//   // إعادة تعيين جميع العادات
//   Future<void> resetAllHabits() async {
//     final userId = _supabaseService.currentUserId;
//     if (userId == null) throw 'يجب تسجيل الدخول أولاً';
    
//     await _supabaseService.client
//         .from('habits')
//         .update({'completed': false})
//         .eq('user_id', userId);
//   }
  
//   // الحصول على عدد الأيام
// Future<int> getDayCount() async {
//   final userId = _supabaseService.currentUserId;
//   if (userId == null) return 1;

//   final response = await _supabaseService.client
//       .from('user_stats')
//       .select('day_count')
//       .eq('user_id', userId)
//       .maybeSingle();

//   if (response == null) {
//     await _supabaseService.client.from('user_stats').insert({
//       'user_id': userId,
//       'day_count': 1,
//       'last_reset_date': DateTime.now().toIso8601String()
//     });
//     return 1;
//   }

//   return response['day_count'] ?? 1;
// }

  
//   // تحديث عدد الأيام
//   Future<void> updateDayCount(int dayCount) async {
//     final userId = _supabaseService.currentUserId;
//     if (userId == null) throw 'يجب تسجيل الدخول أولاً';
    
//     await _supabaseService.client
//         .from('user_stats')
//         .update({
//           'day_count': dayCount,
//           'last_reset_date': DateTime.now().toIso8601String()
//         })
//         .eq('user_id', userId);
//   }
  
//   // الحصول على تاريخ آخر إعادة ضبط
// Future<DateTime?> getLastResetDate() async {
//   final userId = _supabaseService.currentUserId;
//   if (userId == null) return null;

//   final response = await _supabaseService.client
//       .from('user_stats')
//       .select('last_reset_date')
//       .eq('user_id', userId)
//       .maybeSingle();

//   if (response == null || response['last_reset_date'] == null) {
//     return null;
//   }

//   return DateTime.parse(response['last_reset_date']);
// }

// }