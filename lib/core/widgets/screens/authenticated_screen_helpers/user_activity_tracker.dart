import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../exports.dart';
import '../../../../providers/security_update_user_extra_latest_load_if_recent_provider.dart';

/// Widget that tracks user activity (taps, scrolls, double taps) and calls
/// the activity tracking API with throttling (max once every 15 seconds).
///
/// This widget wraps content and tracks interactions without interfering
/// with existing gesture handlers.
class UserActivityTracker extends ConsumerStatefulWidget {
  final Widget child;

  const UserActivityTracker({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<UserActivityTracker> createState() => _UserActivityTrackerState();
}

class _UserActivityTrackerState extends ConsumerState<UserActivityTracker> {
  static final log = scopedLogger(LogCategory.gui);
  DateTime? _lastScrollTime;
  static const Duration _scrollThrottle = Duration(milliseconds: 500);

  void _trackActivity() {
    try {
      final notifier = ref.read(securityUpdateUserExtraLatestLoadIfRecentNotifierProvider.notifier);
      // Fire and forget - don't await to avoid blocking UI
      notifier.trackActivity().catchError((error) {
        // Silently handle errors - activity tracking should not affect app functionality
        log('[core/widgets/screens/authenticated_screen_helpers/user_activity_tracker.dart][_trackActivity] Error tracking activity: $error');
        return false;
      });
    } catch (e) {
      // Silently handle errors - activity tracking should not affect app functionality
      log('[core/widgets/screens/authenticated_screen_helpers/user_activity_tracker.dart][_trackActivity] Error: $e');
    }
  }

  void _handleTap() {
    _trackActivity();
  }

  void _handleDoubleTap() {
    _trackActivity();
  }

  void _handleScroll() {
    final now = DateTime.now();
    // Throttle scroll events to avoid too many calls
    if (_lastScrollTime == null || now.difference(_lastScrollTime!) > _scrollThrottle) {
      _lastScrollTime = now;
      _trackActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Track pointer events (taps, drags, etc.)
      onPointerDown: (_) => _handleTap(),
      // Use GestureDetector for double tap detection
      child: GestureDetector(
        // Track double taps
        onDoubleTap: _handleDoubleTap,
        // Track scroll events via NotificationListener
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              _handleScroll();
            }
            // Return false to allow the notification to continue propagating
            return false;
          },
          child: widget.child,
        ),
      ),
    );
  }
}

// File created: 2025-01-14 12:30:00
