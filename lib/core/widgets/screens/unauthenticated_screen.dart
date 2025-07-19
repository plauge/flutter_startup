import '../../../exports.dart';
import '../../../providers/analytics_provider.dart';
import 'dart:math';

abstract class UnauthenticatedScreen extends BaseScreen {
  static String? _lastTrackedScreen;
  static String? _sessionAnonymousId;

  const UnauthenticatedScreen({super.key});

  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref);

  /// Genererer midlertidig anonymous ID for denne session
  String _getSessionAnonymousId() {
    if (_sessionAnonymousId == null) {
      final random = Random();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _sessionAnonymousId = 'anon_${timestamp}_${random.nextInt(999999)}';
    }
    return _sessionAnonymousId!;
  }

  void _trackScreenView(BuildContext context, WidgetRef ref) {
    try {
      final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
      final screenName = runtimeType.toString();

      // Undgå at tracke samme screen flere gange i træk
      if (_lastTrackedScreen == screenName) return;

      _lastTrackedScreen = screenName;

      final analytics = ref.read(analyticsServiceProvider);

      // BEMÆRK: Vi identificerer ikke anonymous brugere
      // - Dette betyder at MixPanel ikke kan tracke bruger-flows før login
      // - Men det respekterer privacy ved ikke at tildele anonymous IDs
      //
      // Hvis du ønsker anonymous tracking, uncomment linjerne nedenfor:
      // final anonymousId = _getSessionAnonymousId();
      // analytics.identify(anonymousId);

      analytics.track('unauthenticated_screen_viewed', {
        'screen_name': screenName,
        'screen_path': currentPath,
        'user_state': 'anonymous',
        'session_id': _getSessionAnonymousId(), // Kun til event properties
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Analytics fejl påvirker ikke app funktionalitet
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track screen view automatisk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackScreenView(context, ref);
    });

    return buildUnauthenticatedWidget(context, ref);
  }
}

// Created on 2024-12-30 at 16:30
