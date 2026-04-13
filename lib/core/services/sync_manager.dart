import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;

  SyncManager._internal();

  final SyncService _syncService = SyncService();

  bool _isSyncing = false;
  Timer? _debounce;

  Future<void> triggerSync() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      await _syncService.syncData();
    } catch (e) {
      print("❌ Sync error: $e");
    }

    _isSyncing = false;
  }

  void scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), triggerSync);
  }

  void startListening() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        triggerSync();
      }
    });
  }
}