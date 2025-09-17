import '../exports.dart';

/// Service for monitoring app lifecycle events and ensuring realtime connections are maintained
class RealtimeLifecycleService extends WidgetsBindingObserver {
  static final log = scopedLogger(LogCategory.service);
  static RealtimeLifecycleService? _instance;

  RealtimeLifecycleService._();

  static RealtimeLifecycleService get instance {
    _instance ??= RealtimeLifecycleService._();
    return _instance!;
  }

  /// Initialize lifecycle monitoring
  void initialize() {
    log('lib/services/realtime_lifecycle_service.dart: Initializing realtime lifecycle monitoring');

    // Add this as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Initialize the connection service
    RealtimeConnectionService.instance.initialize();
  }

  /// Cleanup lifecycle monitoring
  void dispose() {
    log('lib/services/realtime_lifecycle_service.dart: Disposing realtime lifecycle monitoring');

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Dispose connection service
    RealtimeConnectionService.instance.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        log('📱 lib/services/realtime_lifecycle_service.dart: App resumed - refreshing realtime connections');
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        log('📱 lib/services/realtime_lifecycle_service.dart: App paused');
        break;
      case AppLifecycleState.inactive:
        log('📱 lib/services/realtime_lifecycle_service.dart: App inactive');
        break;
      case AppLifecycleState.detached:
        log('📱 lib/services/realtime_lifecycle_service.dart: App detached');
        break;
      case AppLifecycleState.hidden:
        log('📱 lib/services/realtime_lifecycle_service.dart: App hidden');
        break;
    }
  }

  /// Handle app resumed from background or foreground
  void _handleAppResumed() {
    // Delegate to connection service
    RealtimeConnectionService.instance.handleAppResumed();
  }

  /// Force refresh all realtime connections
  void forceRefreshConnections() {
    log('🔄 lib/services/realtime_lifecycle_service.dart: Force refreshing all realtime connections');
    RealtimeConnectionService.instance.refreshAllStreams();
  }
}

// Created: 2025-01-17 10:30:00
