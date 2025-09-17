import 'dart:async';
import '../exports.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for managing Supabase realtime connections with robust reconnection logic
class RealtimeConnectionService {
  static final log = scopedLogger(LogCategory.service);
  static RealtimeConnectionService? _instance;

  final SupabaseClient _client;
  final Connectivity _connectivity = Connectivity();

  // Connection state tracking
  bool _isConnected = true;
  bool _hasActiveStreams = false;
  Timer? _reconnectionTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Callbacks for stream refreshing
  final List<VoidCallback> _refreshCallbacks = [];

  RealtimeConnectionService._(this._client);

  static RealtimeConnectionService get instance {
    _instance ??= RealtimeConnectionService._(Supabase.instance.client);
    return _instance!;
  }

  /// Initialize connection monitoring
  void initialize() {
    log('lib/services/realtime_connection_service.dart: Initializing realtime connection monitoring');

    // Listen to connectivity changes
    _setupConnectivityListener();

    // Setup Supabase realtime status listener
    _setupRealtimeStatusListener();
  }

  /// Dispose of resources
  void dispose() {
    log('lib/services/realtime_connection_service.dart: Disposing realtime connection service');
    _connectivitySubscription?.cancel();
    _reconnectionTimer?.cancel();
    _refreshCallbacks.clear();
  }

  /// Register a callback to refresh realtime streams
  void registerRefreshCallback(VoidCallback callback) {
    log('lib/services/realtime_connection_service.dart: Registering refresh callback');
    _refreshCallbacks.add(callback);
    _hasActiveStreams = true;
  }

  /// Unregister a refresh callback
  void unregisterRefreshCallback(VoidCallback callback) {
    log('lib/services/realtime_connection_service.dart: Unregistering refresh callback');
    _refreshCallbacks.remove(callback);
    if (_refreshCallbacks.isEmpty) {
      _hasActiveStreams = false;
    }
  }

  /// Force refresh all registered streams
  void refreshAllStreams() {
    if (_refreshCallbacks.isEmpty) {
      log('lib/services/realtime_connection_service.dart: No refresh callbacks registered');
      return;
    }

    log('lib/services/realtime_connection_service.dart: Refreshing ${_refreshCallbacks.length} realtime streams');

    for (final callback in _refreshCallbacks) {
      try {
        callback();
      } catch (e) {
        log('lib/services/realtime_connection_service.dart: Error calling refresh callback: $e');
      }
    }
  }

  /// Handle app resumed from background
  void handleAppResumed() {
    log('📱 lib/services/realtime_connection_service.dart: App resumed - checking realtime connection');

    // Small delay to ensure app is fully ready
    Future.delayed(const Duration(milliseconds: 1000), () {
      _checkAndRefreshConnection();
    });
  }

  /// Setup connectivity change listener
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isConnected = results.any((result) => result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet);

      log('📶 lib/services/realtime_connection_service.dart: Connectivity changed - Connected: $isConnected');

      if (!_isConnected && isConnected) {
        // Connection restored
        _isConnected = true;
        log('✅ lib/services/realtime_connection_service.dart: Network connection restored - refreshing streams');
        _scheduleConnectionRefresh();
      } else if (_isConnected && !isConnected) {
        // Connection lost
        _isConnected = false;
        log('❌ lib/services/realtime_connection_service.dart: Network connection lost');
        _cancelReconnectionTimer();
      } else {
        _isConnected = isConnected;
      }
    });
  }

  /// Setup Supabase realtime status listener
  void _setupRealtimeStatusListener() {
    // Listen to Supabase auth state changes for session renewal
    _client.auth.onAuthStateChange.listen((AuthState authState) {
      if (authState.event == AuthChangeEvent.tokenRefreshed) {
        log('🔄 lib/services/realtime_connection_service.dart: Supabase session refreshed - refreshing realtime streams');
        _scheduleConnectionRefresh();
      } else if (authState.event == AuthChangeEvent.signedIn) {
        log('👤 lib/services/realtime_connection_service.dart: User signed in - refreshing realtime streams');
        _scheduleConnectionRefresh();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        log('👤 lib/services/realtime_connection_service.dart: User signed out - clearing streams');
        _cancelReconnectionTimer();
      }
    });
  }

  /// Check connection and refresh if needed
  void _checkAndRefreshConnection() {
    if (!_isConnected || !_hasActiveStreams) {
      log('lib/services/realtime_connection_service.dart: Skipping refresh - Connected: $_isConnected, HasStreams: $_hasActiveStreams');
      return;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      log('lib/services/realtime_connection_service.dart: No authenticated user - skipping refresh');
      return;
    }

    log('🔄 lib/services/realtime_connection_service.dart: Connection check - refreshing all streams');
    refreshAllStreams();
  }

  /// Schedule a connection refresh with delay
  void _scheduleConnectionRefresh() {
    _cancelReconnectionTimer();

    // Schedule refresh after a short delay to avoid rapid successive calls
    _reconnectionTimer = Timer(const Duration(seconds: 2), () {
      _checkAndRefreshConnection();
    });
  }

  /// Cancel any pending reconnection timer
  void _cancelReconnectionTimer() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Get active streams status
  bool get hasActiveStreams => _hasActiveStreams;
}

// Created: 2025-01-17 10:15:00
