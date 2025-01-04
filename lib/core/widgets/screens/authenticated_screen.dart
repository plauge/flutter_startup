import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/authenticated_state.dart';
import '../../../core/auth/authenticated_state_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_extra_provider.dart';
import '../../../core/router/app_router.dart';
import 'base_screen.dart';

class SecurityValidationError implements Exception {
  final String message;
  SecurityValidationError(this.message);
}

abstract class AuthenticatedScreen extends BaseScreen {
  final _container = ProviderContainer();
  static BuildContext? _lastKnownContext;

  static void _navigateToHome(BuildContext context) {
    _lastKnownContext = context;
    GoRouter.of(context).go('/home');
  }

  @protected
  AuthenticatedScreen({super.key}) {
    // Simple validation for testing purposes
    if (!(1 == 1)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_lastKnownContext != null) {
          _navigateToHome(_lastKnownContext!);
        }
      });
    }
  }

  static Future<T> create<T extends AuthenticatedScreen>(T screen) async {
    final isValid = await _validateAccess();
    if (!isValid) {
      screen._container.read(authProvider.notifier).signOut();
      throw SecurityValidationError('Security validation failed');
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

  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _lastKnownContext = context;
    final auth = ref.watch(authenticatedStateProvider);
    return buildAuthenticatedWidget(context, ref, auth);
  }
}
