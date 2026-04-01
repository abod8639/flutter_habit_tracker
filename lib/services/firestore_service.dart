import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => _userId != null;

  // Get user document reference
  DocumentReference? get _userDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  // Get habits collection reference
  CollectionReference? get _habitsCollection {
    return _userDoc?.collection('habits');
  }

  // Get deleted habits collection reference
  CollectionReference? get _deletedHabitsCollection {
    return _userDoc?.collection('deleted_habits');
  }

  // Upload habits to Firestore
  Future<void> uploadHabits(List<HabitModel> habits) async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Cannot upload: User not logged in');
      return;
    }

    try {
      debugPrint('📤 Uploading ${habits.length} habits to Firestore');

      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      // Update user metadata
      batch.set(
        _userDoc!,
        {
          'email': _auth.currentUser?.email,
          'displayName': _auth.currentUser?.displayName,
          'lastSync': timestamp,
        },
        SetOptions(merge: true),
      );

      // Upload each habit
      for (var habit in habits) {
        final habitDoc = _habitsCollection!.doc(habit.id);
        final habitData = habit.toMap();
        habitData['updatedAt'] = timestamp;

        batch.set(habitDoc, habitData, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Successfully uploaded habits to Firestore');
    } catch (e) {
      debugPrint('❌ Error uploading habits: $e');
      rethrow;
    }
  }

  // Download habits from Firestore
  Future<List<HabitModel>> downloadHabits() async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Cannot download: User not logged in');
      return [];
    }

    try {
      debugPrint('📥 Downloading habits from Firestore');

      final snapshot = await _habitsCollection!.get();

      final habits = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure ID is set from doc if missing in data
        data['id'] = data['id'] ?? doc.id;
        return HabitModel.fromMap(data);
      }).toList();

      // Sort by index for correct order across devices
      habits.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

      debugPrint('✅ Downloaded ${habits.length} habits from Firestore');
      return habits;
    } catch (e) {
      debugPrint('❌ Error downloading habits: $e');
      rethrow;
    }
  }

  // Sync habits (smart merge)
  Future<List<HabitModel>> syncHabits(
    List<HabitModel> localHabits, {
    List<String> localTombstones = const [],
  }) async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Cannot sync: User not logged in');
      return localHabits;
    }

    try {
      debugPrint('🔄 Starting habit sync');

      // Process local tombstones first
      for (var id in localTombstones) {
        // This will delete it on the server and create a server tombstone
        await deleteHabit(id);
      }

      // Download cloud habits
      final cloudHabits = await downloadHabits();

      // Download tombstones
      final deletedSnapshot = await _deletedHabitsCollection!.get();
      final deletedHabitsMap = {
        for (var doc in deletedSnapshot.docs) doc.id: true,
      };

      // Create maps for easier lookup
      final localMap = {for (var h in localHabits) h.id: h};
      final cloudMap = {for (var h in cloudHabits) h.id: h};

      // Merge habits (Last Write Wins strategy)
      final mergedHabits = <HabitModel>[];
      final allIds = {...localMap.keys, ...cloudMap.keys};

      for (var id in allIds) {
        final local = localMap[id];
        final cloud = cloudMap[id];

        if (local == null) {
          // Only in cloud
          mergedHabits.add(cloud!);
        } else if (cloud == null) {
          // Only local
          if (deletedHabitsMap.containsKey(id)) {
            // Was deleted on another device
            debugPrint(
              '🗑️ Habit $id was deleted in cloud, ignoring local copy',
            );
          } else {
            // New local habit
            mergedHabits.add(local);
          }
        } else {
          // In both - compare timestamps
          final localTime =
              local.updatedAt ?? local.completedAt ?? local.createdAt;
          final cloudTime =
              cloud.updatedAt ?? cloud.completedAt ?? cloud.createdAt;

          if (localTime.isAfter(cloudTime)) {
            mergedHabits.add(local);
          } else {
            mergedHabits.add(cloud);
          }
        }
      }

      // Upload merged habits back to cloud
      await uploadHabits(mergedHabits);

      debugPrint('✅ Sync completed: ${mergedHabits.length} habits');
      return mergedHabits;
    } catch (e) {
      debugPrint('❌ Error syncing habits: $e');
      return localHabits; // Return local on error
    }
  }

  // Delete a habit from Firestore
  Future<void> deleteHabit(String habitId) async {
    if (!isUserLoggedIn) return;

    try {
      final batch = _firestore.batch();

      batch.delete(_habitsCollection!.doc(habitId));
      batch.set(_deletedHabitsCollection!.doc(habitId), {
        'deletedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint(
        '🗑️ Deleted habit $habitId from Firestore and recorded tombstone',
      );
    } catch (e) {
      debugPrint('❌ Error deleting habit: $e');
    }
  }

  // Upload habit history (for heatmap)
  Future<void> uploadHabitHistory(String date, String completionRate) async {
    if (!isUserLoggedIn) return;

    try {
      await _userDoc!.collection('habitHistory').doc(date).set({
        'date': date,
        'completionRate': completionRate,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error uploading habit history: $e');
    }
  }

  // Download habit history from Firestore
  Future<Map<String, String>> downloadHabitHistory() async {
    if (!isUserLoggedIn) return {};

    try {
      debugPrint('📥 Downloading habit history from Firestore');
      final snapshot = await _userDoc!.collection('habitHistory').get();

      final Map<String, String> history = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'] as String?;
        final rate = data['completionRate'] as String?;
        if (date != null && rate != null) {
          history[date] = rate;
        }
      }

      debugPrint('✅ Downloaded ${history.length} days of history');
      return history;
    } catch (e) {
      debugPrint('❌ Error downloading habit history: $e');
      return {};
    }
  }

  // Sync habit history (local + cloud)
  Future<Map<String, String>> syncHabitHistory(
    Map<String, String> localHistory,
  ) async {
    if (!isUserLoggedIn) return localHistory;

    try {
      debugPrint('🔄 Syncing habit history');
      final cloudHistory = await downloadHabitHistory();

      // Merge: Cloud wins for simplicity, or we could compare timestamps if we had them for every local entry.
      // For now, let's merge both.
      final mergedHistory = {...localHistory, ...cloudHistory};

      // Upload missing entries from local to cloud
      for (var entry in localHistory.entries) {
        if (!cloudHistory.containsKey(entry.key)) {
          await uploadHabitHistory(entry.key, entry.value);
        }
      }

      return mergedHistory;
    } catch (e) {
      debugPrint('❌ Error syncing habit history: $e');
      return localHistory;
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _userDoc!.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final timestamp = data?['lastSync'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      debugPrint('❌ Error getting last sync time: $e');
    }
    return null;
  }

  // Listen to habit changes in real-time
  Stream<List<HabitModel>> listenToHabits() {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }

    return _habitsCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return HabitModel.fromMap(data);
      }).toList();
    });
  }

  // Delete all user data (for account deletion)
  Future<void> deleteAllUserData() async {
    if (!isUserLoggedIn) return;

    try {
      // Delete all habits
      final habitsSnapshot = await _habitsCollection!.get();
      for (var doc in habitsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all history
      final historySnapshot = await _userDoc!.collection('habitHistory').get();
      for (var doc in historySnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await _userDoc!.delete();

      debugPrint('🗑️ Deleted all user data from Firestore');
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
    }
  }

  // --- Theme Management ---

  // Upload theme settings to Firestore
  Future<void> uploadTheme(
    String themeName,
    ThemeMode mode,
    bool useCustomBg,
    Color? customBgColor,
  ) async {
    if (!isUserLoggedIn) return;

    try {
      debugPrint('📤 Uploading theme settings to Firestore');

      await _userDoc!.collection('settings').doc('theme').set({
        'themeName': themeName,
        'themeMode': mode.toString(), // Store as string
        'useCustomBg': useCustomBg,
        'customBgColor': customBgColor?.value, // Store as int
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Theme settings uploaded successfully');
    } catch (e) {
      debugPrint('❌ Error uploading theme settings: $e');
    }
  }

  // Download theme settings from Firestore
  Future<Map<String, dynamic>?> downloadTheme() async {
    if (!isUserLoggedIn) return null;

    try {
      debugPrint('📥 Downloading theme settings from Firestore');

      final doc = await _userDoc!.collection('settings').doc('theme').get();

      if (doc.exists) {
        debugPrint('✅ Theme settings downloaded');
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('❌ Error downloading theme settings: $e');
    }
    return null;
  }
}
