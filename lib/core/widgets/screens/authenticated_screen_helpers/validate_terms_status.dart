import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../exports.dart'; // Adjusted path, ensure RoutePaths and userExtraNotifierProvider are exported

Future<void> validateTermsStatus(BuildContext? contextForNavigation) async {
  final container = ProviderContainer();
  try {
    // final user = Supabase.instance.client.auth.currentUser; // Not strictly needed for terms check if userExtraAsync has the info

    final userExtraAsync =
        await container.read(userExtraNotifierProvider.future);

    if (userExtraAsync?.termsConfirmed != true) {
      if (contextForNavigation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            if (contextForNavigation.mounted) {
              contextForNavigation.go(RoutePaths.termsOfService);
            } else {
              // Attempt to use GoRouter if context is not mounted, though this might be risky
              // Consider a more robust way to handle navigation if contextForNavigation is not mounted
              GoRouter.of(contextForNavigation).go(RoutePaths.termsOfService);
            }
          } catch (e) {
            // Fallback navigation, also consider robustness
            try {
              Navigator.of(contextForNavigation).pushNamedAndRemoveUntil(
                RoutePaths.termsOfService,
                (route) => false,
              );
            } catch (e) {
              // Log error or handle more gracefully
            }
          }
        });
      } else {
        // Log or handle missing contextForNavigation
      }
    } else {
      // Terms are confirmed or userExtraAsync is null (which implies user might not be fully loaded/problem)
      // Handled by the null check on termsConfirmed
    }
  } catch (e, stackTrace) {
    // Log error
  } finally {
    container.dispose();
  }
}

// Created on: 2024-07-18 11:00
