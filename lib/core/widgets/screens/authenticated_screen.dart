import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/authenticated_state.dart';
import '../../../core/auth/authenticated_state_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_extra_provider.dart';
import 'base_screen.dart';

class SecurityValidationError implements Exception {
  final String message;
  SecurityValidationError(this.message);
}

abstract class AuthenticatedScreen extends BaseScreen {
  final _container = ProviderContainer();

  @protected
  AuthenticatedScreen({super.key}) {
    (() async {
      final isValid = await _validateAccess();
      if (!isValid) {
        _container.read(authProvider.notifier).signOut();
        throw SecurityValidationError('Security validation failed');
      }
    })();
  }

  static Future<T> create<T extends AuthenticatedScreen>(T screen) async {
    final isValid = await _validateAccess();
    if (!isValid) {
      screen._container.read(authProvider.notifier).signOut();
      throw SecurityValidationError('Security validation failed');
    }

    // Validate Terms of Service during creation
    final container = ProviderContainer();
    try {
      final userExtraAsync =
          await container.read(userExtraNotifierProvider.future);
      if (userExtraAsync?.termsConfirmed != true) {
        print('❌ Terms of Service not confirmed during screen creation');
        return screen;
      }
    } finally {
      container.dispose();
    }

    return screen;
  }

  static Future<bool> _validateAccess() async {
    // Skip validation for login process
    if (Supabase.instance.client.auth.currentSession == null) {
      return true;
    }

    final container = ProviderContainer();
    try {
      final userExtraAsync =
          await container.read(userExtraNotifierProvider.future);

      // Hvis der ikke er nogen UserExtra data, returner false
      if (userExtraAsync == null) {
        print('❌ No UserExtra data found');
        return false;
      }

      // Check onboarding status
      final bool isOnboardingComplete = userExtraAsync.onboarding == false;
      print(
          '🔍 Onboarding status: ${isOnboardingComplete ? 'Complete' : 'Incomplete'}');

      return isOnboardingComplete;
    } catch (e) {
      print('❌ Validation error: $e');
      return false;
    } finally {
      container.dispose();
    }
  }

  Future<bool> _validateTermsOfService(BuildContext context) async {
    final container = ProviderContainer();
    try {
      final userExtraAsync =
          await container.read(userExtraNotifierProvider.future);

      if (userExtraAsync?.termsConfirmed != true) {
        print('❌ Terms of Service not confirmed');

        // Don't redirect if we're already on the terms-of-service page
        if (GoRouterState.of(context).location != '/terms-of-service') {
          GoRouter.of(context).go('/terms-of-service');
        }
        return false;
      }
      return true;
    } catch (e) {
      print('❌ Terms of Service validation error: $e');
      return false;
    } finally {
      container.dispose();
    }
  }

  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authenticatedStateProvider);

    // Check Terms of Service
    (() async {
      final termsValid = await _validateTermsOfService(context);
      if (!termsValid) {
        throw SecurityValidationError('Terms of Service not accepted');
      }
    })();

    return buildAuthenticatedWidget(context, ref, auth);
  }
}
