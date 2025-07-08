import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';
import 'package:habit_tracker/services/syncHiveToSupabase.dart';


class HabitRemoteDataSource {
  final bool _isOnline = false;

  Future<void> _checkConnectivity() async {
    // In a real app, this would check for internet connection.
    // For now, we can simulate it.
    // _isOnline = await SupabaseService.hasInternetConnection();
  }

  Future<bool> syncWithSupabase(
      List<HabitModel> habits, Map<DateTime, int> heatmap, String userId) async {
    try {
      await _checkConnectivity();

      if (!_isOnline) {
        debugPrint('⚠️ Device is offline, skipping sync');
        return false;
      }

      debugPrint('🔄 Starting sync with Supabase...');
      final uploadSuccess = await SupabaseService.uploadHabits(habits, userId);

      if (uploadSuccess) {
        await SupabaseService.uploadHeatmapData(heatmap, userId);
        debugPrint('✅ Sync completed successfully');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> downloadFromSupabase(String userId) async {
    try {
      await _checkConnectivity();

      if (!_isOnline) {
        debugPrint('⚠️ Device is offline, cannot download');
        return {};
      }

      debugPrint('📥 Downloading data from Supabase...');
      final cloudHabits = await SupabaseService.downloadHabits(userId);
      final cloudHeatmap = await SupabaseService.downloadHeatmapData(userId);

      debugPrint('✅ Download completed successfully');
      return {'habits': cloudHabits, 'heatmap': cloudHeatmap};
    } catch (e) {
      debugPrint('❌ Error during download: $e');
      return {};
    }
  }
}