import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import '../services/security_update_user_extra_latest_load_if_recent_service.dart';

part 'generated/security_update_user_extra_latest_load_if_recent_provider.g.dart';

// ============================================================================
// CONFIGURATION: Throttle duration - change this value to adjust throttle time
// ============================================================================
const Duration _throttleDuration = Duration(minutes: 1);
// ============================================================================

@riverpod
SecurityUpdateUserExtraLatestLoadIfRecentService securityUpdateUserExtraLatestLoadIfRecentService(Ref ref) {
  final supabaseService = SupabaseService();
  // Use the wrapped client which logs API calls
  return SecurityUpdateUserExtraLatestLoadIfRecentService(supabaseService.client);
}

/// Notifier that handles throttling for user activity tracking API calls.
/// Ensures API is called at most once every minute (configurable via _throttleDuration).
@riverpod
class SecurityUpdateUserExtraLatestLoadIfRecentNotifier extends _$SecurityUpdateUserExtraLatestLoadIfRecentNotifier {
  static final log = scopedLogger(LogCategory.provider);
  DateTime? _lastCallTime;
  Future<bool>? _pendingCall;

  @override
  Future<bool> build() async {
    // Initial state - no call made yet
    return false;
  }

  /// Tracks user activity and calls API if throttle period has passed.
  /// Returns the result of the API call (cached if within throttle period).
  Future<bool> trackActivity() async {
    final now = DateTime.now();

    // If we have a pending call, return that instead of making a new one
    if (_pendingCall != null) {
      log('[providers/security_update_user_extra_latest_load_if_recent_provider.dart][trackActivity] Reusing pending call');
      return _pendingCall!;
    }

    // Check if we're within throttle period
    if (_lastCallTime != null) {
      final timeSinceLastCall = now.difference(_lastCallTime!);
      if (timeSinceLastCall < _throttleDuration) {
        log('[providers/security_update_user_extra_latest_load_if_recent_provider.dart][trackActivity] Throttled - last call was ${timeSinceLastCall.inSeconds}s ago, need ${_throttleDuration.inMinutes} minute(s)');
        // Return cached result if available, otherwise return last known state
        return state.valueOrNull ?? false;
      }
    }

    // Make the API call
    log('[providers/security_update_user_extra_latest_load_if_recent_provider.dart][trackActivity] Calling API (throttle period passed)');
    _lastCallTime = now;

    try {
      final service = ref.read(securityUpdateUserExtraLatestLoadIfRecentServiceProvider);
      _pendingCall = service.updateUserExtraLatestLoadIfRecent();
      final result = await _pendingCall!;
      _pendingCall = null;

      log('[providers/security_update_user_extra_latest_load_if_recent_provider.dart][trackActivity] Successfully completed operation. Result: $result');
      state = AsyncData(result);
      return result;
    } catch (error, stackTrace) {
      _pendingCall = null;
      log('❌ [providers/security_update_user_extra_latest_load_if_recent_provider.dart][trackActivity] Error: $error');
      log('❌ [providers/security_update_user_extra_latest_load_if_recent_provider.dart][trackActivity] Stack trace: $stackTrace');
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

// File created: 2025-01-14 12:00:00

