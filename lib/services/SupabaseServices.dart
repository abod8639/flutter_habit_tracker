// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:habit_tracker/models/habit_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseService extends GetxService {
//   static const String _supabaseUrl = 'YOUR_SUPABASE_URL';
//   static const String _supabaseKey = 'YOUR_SUPABASE_KEY';
//       // anonKey:''

//   late final SupabaseClient _client;
//   User? currentUser;

//   Future<SupabaseService> init() async {
//     await Supabase.initialize(
//       url: _supabaseUrl,
//       anonKey: _supabaseKey,
//     );
//     _client = Supabase.instance.client;
//     currentUser = _client.auth.currentUser;
//     return this;
//   }

//   Future<void> initialize() async {
//     await init();
//   }

//   Future<User?> getCurrentUser() async {
//     currentUser = _client.auth.currentUser;
//     return currentUser;
//   }

//   Future<User?> signUp({required String email, required String password}) async {
//     final response = await _client.auth.signUp(
//       email: email,
//       password: password,
//     );
//     currentUser = response.user;
//     return currentUser;
//   }

//   Future<User?> signIn({required String email, required String password}) async {
//     final response = await _client.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );
//     currentUser = response.user;
//     return currentUser;
//   }

//   Future<void> signOut() async {
//     await _client.auth.signOut();
//     currentUser = null;
//   }

//   Future<List<HabitModel>> fetchHabits() async {
//     if (currentUser == null) return [];

//     final response = await _client
//         .from('habits')
//         .select()
//         .eq('user_id', currentUser!.id)
//         .order('created_at', ascending: true);

//     return (response as List).map((habit) => HabitModel.fromMap(habit)).toList();
//   }

//   Future<void> syncHabits(List<List<dynamic>> habits) async {
//     if (currentUser == null) return;

//     try {
//       // Fetch existing habits
//       final existingHabits = await fetchHabits();
      
//       // Delete all existing habits
//       for (var habit in existingHabits) {
//         if (habit.id != null) {
//           await deleteHabit(habit.id!);
//         }
//       }
      
//       // Add all current habits
//       for (var habit in habits) {
//         await addHabit(habit[0], isCompleted: habit[1]);
//       }
//     } catch (e) {
//       debugPrint('Error syncing habits: $e');
//     }
//   }

//   Future<void> addHabit(String name, {bool isCompleted = false}) async {
//     if (currentUser == null) return;

//     final habitData = HabitModel(
//       id: null,
//       userId: currentUser!.id,
//       name: name,
//       isCompleted: isCompleted,
//       createdAt: DateTime.now(),
//       completedAt: isCompleted ? DateTime.now() : null,
//     ).toMap();

//     await _client.from('habits').insert(habitData);
//   }

//   Future<void> updateHabit(HabitModel habit) async {
//     if (currentUser == null || habit.id == null) return;

//     await _client.from('habits').update(habit.toMap()).eq('id', habit.id.toString() );
//   }

//   Future<void> deleteHabit(String habitId) async {
//     if (currentUser == null) return;

//     await _client.from('habits').delete().eq('id', habitId);
//   }

//   Future<void> resetAllHabits() async {
//     if (currentUser == null) return;

//     final habits = await fetchHabits();
//     for (var habit in habits) {
//       habit.isCompleted = false;
//       habit.completedAt = null;
//       await updateHabit(habit);
//     }
//   }
// }