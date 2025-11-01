import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../exports.dart';

final log = scopedLogger(LogCategory.gui);

/// Widget that handles navigation to phone_code screen when active calls are detected.
/// This widget wraps the child and listens for active phone codes in the background.
class ActivePhoneCodesNavigationHandler extends ConsumerWidget {
  final Widget child;

  const ActivePhoneCodesNavigationHandler({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Skip navigation if already on phone_code screen or home screen
    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (currentPath != RoutePaths.phoneCode && currentPath != RoutePaths.home) {
      // Listen for active phone codes and navigate when active calls are detected
      // ref.listen() must be called in build() - Riverpod handles deduplication automatically
      ref.listen(phoneCodesRealtimeStreamProvider, (previous, next) {
        final bool prevHasActiveCalls = previous?.maybeWhen(data: (codes) => codes.isNotEmpty, orElse: () => false) ?? false;
        final bool nextHasActiveCalls = next.maybeWhen(data: (codes) => codes.isNotEmpty, orElse: () => false);
        
        if (!prevHasActiveCalls && nextHasActiveCalls) {
          log('Redirecting to phone_code due to active calls from lib/core/widgets/screens/authenticated_screen_helpers/handle_active_phone_codes_navigation.dart');
          // Check home version - if version 2 (beta), navigate to home instead of phoneCode
          ref.read(homeVersionProvider.future).then((homeVersion) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                if (homeVersion == 2) {
                  context.go(RoutePaths.home);
                } else {
                  context.go(RoutePaths.phoneCode);
                }
              }
            });
          });
        }
      });
    }

    return child;
  }
}

// Created: 2025-01-20

