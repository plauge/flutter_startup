import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/security_app_status_response.dart';
import '../services/security_app_status_service.dart';
import 'supabase_provider.dart';
import '../utils/app_logger.dart';

part 'generated/security_app_status_provider.g.dart';

// ============================================================================
// CONFIGURATION: Throttle duration - change this value to adjust throttle time
// ============================================================================
const Duration _throttleDuration = Duration(minutes: 1);
// ============================================================================

@riverpod
SecurityAppStatusService securityAppStatusService(SecurityAppStatusServiceRef ref) {
  final client = ref.read(supabaseClientProvider);
  return SecurityAppStatusService(client);
}

/// Provider for fetching app status data from Supabase with 1-minute throttling.
/// Ensures API is called at most once per minute.
/// Uses keepAlive to prevent disposal and maintain throttling state.
@Riverpod(keepAlive: true)
class SecurityAppStatus extends _$SecurityAppStatus {
  static final log = scopedLogger(LogCategory.provider);
  DateTime? _lastCallTime;
  Future<SecurityAppStatusResponse>? _pendingCall;
  bool _isProcessing = false;

  @override
  Future<SecurityAppStatusResponse> build() async {
    // Initial load - always fetch on first build
    return _fetchAppStatus();
  }

  Future<SecurityAppStatusResponse> _fetchAppStatus() async {
    final now = DateTime.now();

    // CRITICAL: Check pending call FIRST before any other checks to prevent race conditions
    if (_pendingCall != null) {
      log('[providers/security_app_status_provider.dart][_fetchAppStatus] Reusing pending call');
      return _pendingCall!;
    }

    // CRITICAL: Check if already processing to prevent simultaneous calls
    if (_isProcessing) {
      log('[providers/security_app_status_provider.dart][_fetchAppStatus] Already processing, waiting for pending call');
      // Wait a bit and check again
      await Future.delayed(const Duration(milliseconds: 100));
      if (_pendingCall != null) {
        return _pendingCall!;
      }
    }

    // Check if we're within throttle period
    if (_lastCallTime != null) {
      final timeSinceLastCall = now.difference(_lastCallTime!);
      if (timeSinceLastCall < _throttleDuration) {
        log('[providers/security_app_status_provider.dart][_fetchAppStatus] Throttled - last call was ${timeSinceLastCall.inSeconds}s ago, need ${_throttleDuration.inSeconds}s');
        // Return cached result if available
        if (state.valueOrNull != null) {
          return state.valueOrNull!;
        }
        // If no cached value, make the call anyway
      }
    }

    // Make the API call
    return _makeApiCall(now);
  }

  Future<SecurityAppStatusResponse> _makeApiCall(DateTime now) async {
    log('[providers/security_app_status_provider.dart][_makeApiCall] Calling API (throttle period passed)');

    // CRITICAL FIX: Set lock and both _lastCallTime and _pendingCall atomically
    // BEFORE making the call to prevent race conditions where multiple calls
    // can pass the throttle check simultaneously
    _isProcessing = true;
    _lastCallTime = now;
    
    final service = ref.read(securityAppStatusServiceProvider);
    _pendingCall = service.getAppStatus();

    try {
      final result = await _pendingCall!;
      _pendingCall = null;
      _isProcessing = false;
      
      log('[providers/security_app_status_provider.dart][_makeApiCall] Successfully got app status');
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      _pendingCall = null;
      _isProcessing = false;
      log('[providers/security_app_status_provider.dart][_makeApiCall] Error: $error');
      log('[providers/security_app_status_provider.dart][_makeApiCall] Stack trace: $stackTrace');
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  /// Public method to refresh data (respects throttling)
  Future<SecurityAppStatusResponse> refresh() async {
    return _fetchAppStatus();
  }
}

// File created: 2025-01-06 15:30
// Updated: 2025-01-27 - Added 1-minute throttling with keepAlive
