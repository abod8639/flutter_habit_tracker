import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/HAbit_Models.dart';

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
        return HabitModel.fromMap(data);
      }).toList();

      debugPrint('✅ Downloaded ${habits.length} habits from Firestore');
      return habits;
    } catch (e) {
      debugPrint('❌ Error downloading habits: $e');
      rethrow;
    }
  }

  // Sync habits (smart merge)
  Future<List<HabitModel>> syncHabits(List<HabitModel> localHabits) async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Cannot sync: User not logged in');
      return localHabits;
    }

    try {
      debugPrint('🔄 Starting habit sync');
      
      // Download cloud habits
      final cloudHabits = await downloadHabits();
      
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
          mergedHabits.add(local);
        } else {
          // In both - compare timestamps
          // For now, we'll use createdAt as a proxy for updatedAt
          // In a real app, you'd add updatedAt field
          final localTime = local.completedAt ?? local.createdAt;
          final cloudTime = cloud.completedAt ?? cloud.createdAt;
          
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
      await _habitsCollection!.doc(habitId).delete();
      debugPrint('🗑️ Deleted habit $habitId from Firestore');
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
}
