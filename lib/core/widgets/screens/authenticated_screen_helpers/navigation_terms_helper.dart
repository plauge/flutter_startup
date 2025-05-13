import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

class NavigationTermsHelper {
  static BuildContext? _lastKnownContext;

  static void navigateToOnboarding(BuildContext context) {
    _lastKnownContext = context;
    GoRouter.of(context).go('/onboarding/begin');
  }

  static void navigateToTerms(BuildContext context) {
    _lastKnownContext = context;
    print(
        '🔄 Attempting to navigate to terms page with context: ${context.hashCode}');
    try {
      context.go(RoutePaths.termsOfService);
      print('✅ Navigation to terms page initiated');
    } catch (e) {
      print('❌ Error navigating to terms page: $e');
      try {
        GoRouter.of(context).go(RoutePaths.termsOfService);
        print('✅ Navigation to terms page initiated via GoRouter.of()');
      } catch (e) {
        print('❌ Error navigating to terms page via GoRouter.of(): $e');
      }
    }
  }

  // Sikrer at _lastKnownContext altid er opdateret og gyldig
  static void updateLastKnownContext(BuildContext context) {
    if (context.mounted) {
      _lastKnownContext = context;
      print('✅ _lastKnownContext updated to: ${context.hashCode}');
    }
  }

  static BuildContext? getLastKnownContext() {
    return _lastKnownContext;
  }
}
