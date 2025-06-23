// 4. Usage examples in your UI
import 'package:flutter/material.dart';
import 'package:habit_tracker/data/habit_db.dart';

class HabitListWidget extends StatefulWidget {
  const HabitListWidget({super.key});

  @override
  _HabitListWidgetState createState() => _HabitListWidgetState();
}

class _HabitListWidgetState extends State<HabitListWidget> {
  final Habitdb habitdb = Habitdb();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load local data first
    habitdb.loadData();

    // Check if we need to sync with cloud
    // if (habitdb.needsSync()) {
    //   await _syncData();
    // }

    setState(() {});
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    try {
      await habitdb.syncWithSupabase();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Data synced successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Sync failed: $e')));
    }

    setState(() => _isSyncing = false);
  }

  Future<void> _downloadFromCloud() async {
    setState(() => _isSyncing = true);

    try {
      await habitdb.downloadFromSupabase();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Data downloaded from cloud')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Download failed: $e')));
    }

    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        actions: [
          if (_isSyncing)
            Center(child: CircularProgressIndicator(color: Colors.white))
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'sync':
                    _syncData();
                    break;
                  case 'download':
                    _downloadFromCloud();
                    break;
                  case 'force_sync':
                    habitdb.forceSyncWithSupabase();
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'sync',
                      child: Row(
                        children: [
                          Icon(Icons.sync),
                          SizedBox(width: 8),
                          Text('Sync to Cloud'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download from Cloud'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'force_sync',
                      child: Row(
                        children: [
                          Icon(Icons.sync_alt),
                          SizedBox(width: 8),
                          Text('Force Sync'),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Sync status indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: _getSyncStatusColor(),
            child: Text(
              _getSyncStatusText(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          // Your existing habit list UI here
          Expanded(
            child: ListView.builder(
              itemCount: habitdb.todaysHabitList.length,
              itemBuilder: (context, index) {
                final habit = habitdb.getHabitByIndex(index);
                return ListTile(
                  title: Text(habit?.name ?? ''),
                  trailing: Checkbox(
                    value: habit?.isCompleted ?? false,
                    onChanged: (value) {
                      habitdb.toggleHabitByIndex(index, value ?? false);
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getSyncStatusColor() {
    if (_isSyncing) return Colors.orange;

    final lastSync = habitdb.getLastSyncTime();
    if (lastSync == null) return Colors.red;

    final timeDifference = DateTime.now().difference(lastSync);
    if (timeDifference.inHours > 24) return Colors.red;
    if (timeDifference.inHours > 1) return Colors.orange;

    return Colors.green;
  }

  String _getSyncStatusText() {
    if (_isSyncing) return 'Syncing...';

    final lastSync = habitdb.getLastSyncTime();
    if (lastSync == null) return 'Never synced - Tap sync to backup';

    final timeDifference = DateTime.now().difference(lastSync);
    if (timeDifference.inMinutes < 60) {
      return 'Last synced: ${timeDifference.inMinutes}m ago';
    }
    if (timeDifference.inHours < 24) {
      return 'Last synced: ${timeDifference.inHours}h ago';
    }
    return 'Last synced: ${timeDifference.inDays}d ago';
  }
}
