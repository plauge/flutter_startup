import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/authenticated_state.dart';
import '../../../core/auth/authenticated_state_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_extra_provider.dart';
import '../../../screens/authenticated/demo.dart';
import '../../../screens/authenticated/profile.dart';
import '../../../screens/authenticated/contacts.dart';
import '../../../screens/authenticated/contact_verification.dart';
import 'base_screen.dart';

class SecurityValidationError implements Exception {
  final String message;
  SecurityValidationError(this.message);
}

abstract class AuthenticatedScreen extends BaseScreen {
  final _container = ProviderContainer();
  static BuildContext? _lastKnownContext;

  // Array of pages that should be validated
  static final List<Type> _validatedPages = [
    DemoScreen,
    ProfilePage,
  ];

  // Array of pages that should be validated
  // Disse sider kræver at bruger har gennemført onboarding
  static final List<Type> _onboardingValidatedPages = [
    ContactsScreen,
    ContactVerificationScreen,
  ];

  @protected
  AuthenticatedScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_lastKnownContext != null) {
        final currentPath = GoRouter.of(_lastKnownContext!)
            .routerDelegate
            .currentConfiguration
            .fullPath;
        if (currentPath != '/terms-of-service') {
          _validateTermsStatus();
        }
      }
    });
  }

  static void _navigateToOnboarding(BuildContext context) {
    _lastKnownContext = context;
    GoRouter.of(context).go('/onboarding/begin');
  }

  static void _navigateToTerms(BuildContext context) {
    _lastKnownContext = context;
    GoRouter.of(context).go('/terms-of-service');
  }

  void _validateTermsStatus() {
    print('BEGIN VALIDATING TERMS');
    //if (_validatedPages.contains(runtimeType)) {
    print('🔍🔍🔍🔍/////// Validating page: $runtimeType');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final userExtraAsync =
            await _container.read(userExtraNotifierProvider.future);
        print('🔍 UserExtra data: $userExtraAsync');
        if (userExtraAsync?.termsConfirmed != true) {
          print('⚠️ Onboarding is true - redirecting to home');
          if (_lastKnownContext != null) {
            print('🔄 Navigating to home page');
            _navigateToTerms(_lastKnownContext!);
          } else {
            print('❌ No context available for navigation');
          }
        } else {
          print('✅ Onboarding check passed - staying on page');
        }
      } catch (e) {
        print('❌ Error reading UserExtra: $e');
      }
    });
    // } else {
    //   print('🔍 Page not in validation list: $runtimeType');
    // }
  }

  static Future<T> create<T extends AuthenticatedScreen>(T screen) async {
    // Save for later use
    // final isValid = await _validateAccess();
    // if (!isValid) {
    //   screen._container.read(authProvider.notifier).signOut();
    //   throw SecurityValidationError('Security validation failed');
    // }
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
    print('🏗️ BUILD: Loading screen: ${runtimeType.toString()}');

    // Perform validation for onboarding pages
    if (_onboardingValidatedPages.contains(runtimeType)) {
      print(
          '🔒 VALIDATION: Screen ${runtimeType.toString()} requires onboarding validation');
      final userExtraAsync = ref.watch(userExtraNotifierProvider);

      return userExtraAsync.when(
        loading: () {
          print(
              '⌛ STATUS: Screen ${runtimeType.toString()} is loading user data');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stack) {
          print(
              '❌ ERROR: Screen ${runtimeType.toString()} failed to load user data: $error');
          return const Scaffold(
            body: Center(
              child: Text('Error loading user data'),
            ),
          );
        },
        data: (userExtra) {
          if (userExtra?.onboarding == true) {
            print(
                '🔄 REDIRECT: Screen ${runtimeType.toString()} redirecting to onboarding due to incomplete status');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToOnboarding(context);
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          print(
              '✅ SUCCESS: Screen ${runtimeType.toString()} loaded successfully with completed onboarding');
          final auth = ref.watch(authenticatedStateProvider);
          return buildAuthenticatedWidget(context, ref, auth);
        },
      );
    }

    print(
        '✅ RENDER: Screen ${runtimeType.toString()} rendering without onboarding validation');
    final auth = ref.watch(authenticatedStateProvider);
    return buildAuthenticatedWidget(context, ref, auth);
  }
}
