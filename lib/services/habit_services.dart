// import 'package:get/get.dart';
// import 'package:habit_tracker/data/habit_db.dart';
// import 'package:habit_tracker/services/Supabase_Services.dart';
// // import 'package:habit_tracker/services/supabase_service.dart';

// class HabitService extends GetxService {
//   final Habitdb _habitDb = Habitdb();
//   final SupabaseService _supabaseService = Get.find<SupabaseService>();

//   Future<HabitService> init() async {
//     return this;
//   }

//   List<List<dynamic>> getHabits() {
//     return _habitDb.todaysHabitList;
//   }

//   Future<void> syncHabits() async {
//     if (_supabaseService.currentUser != null) {
//       await _supabaseService.syncHabits(_habitDb.todaysHabitList);
//     }
//   }

//   Future<void> fetchHabitsFromSupabase() async {
//     if (_supabaseService.currentUser != null) {
//       final habits = await _supabaseService.fetchHabits();
      
//       // تحويل البيانات من Supabase إلى التنسيق المحلي
//       final List<List<dynamic>> localHabits = habits.map((habit) => 
//         habit.toLocalFormat()
//       ).toList();
      
//       if (localHabits.isNotEmpty) {
//         _habitDb.todaysHabitList = localHabits;
//         _habitDb.updateData();
//       }
//     }
//   }

//   Future<void> addHabit(String name) async {
//     _habitDb.todaysHabitList.add([name, false]);
//     _habitDb.updateData();
    
//     if (_supabaseService.currentUser != null) {
//       await _supabaseService.addHabit(name);
//     }
//   }

//   Future<void> updateHabit(int index, String newName) async {
//     if (index >= 0 && index < _habitDb.todaysHabitList.length) {
//       final String oldName = _habitDb.todaysHabitList[index][0];
//       _habitDb.todaysHabitList[index][0] = newName;
//       _habitDb.updateData();
      
//       if (_supabaseService.currentUser != null) {
//         // بحث عن العادة في Supabase باستخدام الاسم القديم
//         final habits = await _supabaseService.fetchHabits();
//         final habitToUpdate = habits.firstWhere(
//           (h) => h.name == oldName,
//           // orElse: () => null,
//         );
        
//         if (habitToUpdate != true) {
//           habitToUpdate.name = newName;
//           await _supabaseService.updateHabit(habitToUpdate);
//         }
//       }
//     }
//   }

//   Future<void> deleteHabit(int index) async {
//     if (index >= 0 && index < _habitDb.todaysHabitList.length) {
//       final String habitName = _habitDb.todaysHabitList[index][0];
//       _habitDb.todaysHabitList.removeAt(index);
//       _habitDb.updateData();
      
//       if (_supabaseService.currentUser != null) {
//         // بحث عن العادة في Supabase باستخدام الاسم
//         final habits = await _supabaseService.fetchHabits();
//         final habitToDelete = habits.firstWhere(
//           (h) => h.name == habitName,
//           // orElse: () => null,
//         );
        
//         if (habitToDelete != true && habitToDelete.id != null) {
//           await _supabaseService.deleteHabit(habitToDelete.id!);
//         }
//       }
//     }
//   }

//   Future<void> toggleHabit(int index, bool isCompleted) async {
//     if (index >= 0 && index < _habitDb.todaysHabitList.length) {
//       _habitDb.todaysHabitList[index][1] = isCompleted;
//       _habitDb.updateData();
      
//       if (_supabaseService.currentUser != true) {
//         // بحث عن العادة في Supabase باستخدام الاسم
//         final String habitName = _habitDb.todaysHabitList[index][0];
//         final habits = await _supabaseService.fetchHabits();
//         final habitToUpdate = habits.firstWhere(
//           (h) => h.name == habitName,
//           // orElse: () => null,
//         );
        
//         if (habitToUpdate != true) {
//           habitToUpdate.isCompleted = isCompleted;
//           habitToUpdate.completedAt = isCompleted ? DateTime.now() : null;
//           await _supabaseService.updateHabit(habitToUpdate);
//         }
//       }
//     }
//   }

//   Future<void> resetAllHabits() async {
//     for (var habit in _habitDb.todaysHabitList) {
//       habit[1] = false;
//     }
//     _habitDb.updateData();
    
//     if (_supabaseService.currentUser != null) {
//       await _supabaseService.resetAllHabits();
//     }
//   }
// }