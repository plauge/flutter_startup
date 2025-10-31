import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../exports.dart';

final log = scopedLogger(LogCategory.gui);

void handleActivePhoneCodesNavigation(BuildContext context, WidgetRef ref) {
  // Skip navigation if already on phone_code screen
  final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
  if (currentPath == RoutePaths.phoneCode) {
    return;
  }

  // Listen for active phone codes and navigate when active calls are detected
  ref.listen(phoneCodesRealtimeStreamProvider, (previous, next) {
    final bool prevHasActiveCalls = previous?.maybeWhen(data: (codes) => codes.isNotEmpty, orElse: () => false) ?? false;
    final bool nextHasActiveCalls = next.maybeWhen(data: (codes) => codes.isNotEmpty, orElse: () => false);
    
    if (!prevHasActiveCalls && nextHasActiveCalls) {
      log('Redirecting to phone_code due to active calls from lib/core/widgets/screens/authenticated_screen_helpers/handle_active_phone_codes_navigation.dart');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(RoutePaths.phoneCode);
        }
      });
    }
  });
}

// Created: 2025-01-20

