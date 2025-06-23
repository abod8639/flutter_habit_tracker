// pubspec.yaml dependencies to add:
/*
dependencies:
  supabase_flutter: ^2.5.6
  internet_connection_checker: ^1.0.0+1
*/

// SQL for Supabase tables:
/*
-- Create habits table
CREATE TABLE habits (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create habit_heatmap table
CREATE TABLE habit_heatmap (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  date TEXT NOT NULL,
  completion_rate INTEGER DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Create indexes for better performance
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_created_at ON habits(created_at);
CREATE INDEX idx_heatmap_user_id ON habit_heatmap(user_id);
CREATE INDEX idx_heatmap_date ON habit_heatmap(date);

-- Enable Row Level Security (RLS)
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_heatmap ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS (adjust based on your authentication setup)
CREATE POLICY "Users can only access their own habits" ON habits
  FOR ALL USING (auth.uid()::text = user_id);

CREATE POLICY "Users can only access their own heatmap data" ON habit_heatmap
  FOR ALL USING (auth.uid()::text = user_id);
*/

// 1. Supabase Service Class
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/models/date_time.dart';

class SupabaseService {
  // static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  // static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  // static Future<void> initialize() async {
  //   try {
  //     await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  //     debugPrint('✅ Supabase initialized successfully');
  //   } catch (e) {
  //     debugPrint('❌ Error initializing Supabase: $e');
  //     rethrow;
  //   }
  // }

  // Check internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetConnectionChecker.instance.hasConnection;
      return result;
    } catch (e) {
      debugPrint('⚠️ Error checking internet connection: $e');
      return false;
    }
  }

  // Upload habits to Supabase
  static Future<bool> uploadHabits(
    List<HabitModel> habits,
    String userId,
  ) async {
    try {
      if (!await hasInternetConnection()) {
        debugPrint('⚠️ No internet connection for upload');
        return false;
      }

      // Convert habits to JSON format for Supabase
      final habitsData =
          habits
              .map(
                (habit) => {
                  'id': habit.id,
                  'user_id': userId,
                  'name': habit.name,
                  'is_completed': habit.isCompleted,
                  'created_at': habit.createdAt.toIso8601String(),
                  'completed_at': habit.completedAt?.toIso8601String(),
                  'updated_at': DateTime.now().toIso8601String(),
                },
              )
              .toList();

      // Upsert habits (insert or update if exists)
      await client.from('habits').upsert(habitsData);

      debugPrint('✅ Successfully uploaded ${habits.length} habits to Supabase');
      return true;
    } catch (e) {
      debugPrint('❌ Error uploading habits to Supabase: $e');
      return false;
    }
  }

  // Download habits from Supabase
  static Future<List<HabitModel>> downloadHabits(String userId) async {
    try {
      if (!await hasInternetConnection()) {
        debugPrint('⚠️ No internet connection for download');
        return [];
      }

      final response = await client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      final List<HabitModel> habits =
          (response as List).map((habitData) {
            return HabitModel(
              id: habitData['id'],
              name: habitData['name'],
              isCompleted: habitData['is_completed'] ?? false,
              createdAt: DateTime.parse(habitData['created_at']),
              completedAt:
                  habitData['completed_at'] != null
                      ? DateTime.parse(habitData['completed_at'])
                      : null,
            );
          }).toList();

      debugPrint(
        '✅ Successfully downloaded ${habits.length} habits from Supabase',
      );
      return habits;
    } catch (e) {
      debugPrint('❌ Error downloading habits from Supabase: $e');
      return [];
    }
  }

  // Upload heatmap data
  static Future<bool> uploadHeatmapData(
    Map<DateTime, int> heatmapData,
    String userId,
  ) async {
    try {
      if (!await hasInternetConnection()) {
        debugPrint('⚠️ No internet connection for heatmap upload');
        return false;
      }

      final heatmapEntries =
          heatmapData.entries
              .map(
                (entry) => {
                  'user_id': userId,
                  'date': convertDateTimeToString(entry.key),
                  'completion_rate': entry.value,
                  'updated_at': DateTime.now().toIso8601String(),
                },
              )
              .toList();

      await client.from('habit_heatmap').upsert(heatmapEntries);

      debugPrint('✅ Successfully uploaded heatmap data to Supabase');
      return true;
    } catch (e) {
      debugPrint('❌ Error uploading heatmap data: $e');
      return false;
    }
  }

  // Download heatmap data
  static Future<Map<DateTime, int>> downloadHeatmapData(String userId) async {
    try {
      if (!await hasInternetConnection()) {
        debugPrint('⚠️ No internet connection for heatmap download');
        return {};
      }

      final response = await client
          .from('habit_heatmap')
          .select()
          .eq('user_id', userId);

      final Map<DateTime, int> heatmapData = {};

      for (final entry in response as List) {
        final date = createDateTimeObject(entry['date']);
        heatmapData[date] = entry['completion_rate'] ?? 0;
      }

      debugPrint('✅ Successfully downloaded heatmap data from Supabase');
      return heatmapData;
    } catch (e) {
      debugPrint('❌ Error downloading heatmap data: $e');
      return {};
    }
  }

  // Delete all user data from Supabase
  static Future<bool> deleteUserData(String userId) async {
    try {
      if (!await hasInternetConnection()) {
        debugPrint('⚠️ No internet connection for deletion');
        return false;
      }

      // Delete habits
      await client.from('habits').delete().eq('user_id', userId);

      // Delete heatmap data
      await client.from('habit_heatmap').delete().eq('user_id', userId);

      debugPrint('✅ Successfully deleted user data from Supabase');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
      return false;
    }
  }
}
