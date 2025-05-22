import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idtruster/exports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/authenticated_state.dart';
import '../../../core/auth/authenticated_state_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_extra_provider.dart';
import '../../../providers/auth_validation_provider.dart';
import '../../../services/auth_validation_service.dart';
import '../../../screens/authenticated/demo.dart';
import '../../../screens/authenticated/profile.dart';
import '../../../screens/authenticated/contacts.dart';
import '../../../screens/authenticated/contact_verification.dart';
import 'base_screen.dart';
import 'dart:convert';
import '../../../core/constants/storage_constants.dart';
import '../../../models/user_storage_data.dart';
import '../../../providers/storage/storage_provider.dart';
import '../../../utils/aes_gcm_encryption_utils.dart';
// import '../../../core/constants/route_paths.dart';
import '../../../providers/security_provider.dart';
import '../../../providers/security_validation_provider.dart';
import 'authenticated_screen_helpers/validate_security_status.dart';
import 'authenticated_screen_helpers/add_current_user_if_not_exists.dart';
import 'authenticated_screen_helpers/validate_auth_session.dart';
import 'authenticated_screen_helpers/validate_terms_status.dart';

abstract class AuthenticatedScreen extends BaseScreen {
  final _container = ProviderContainer();
  static BuildContext? _lastKnownContext;

  /// Whether this screen requires PIN code verification
  final bool pin_code_protected;

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
  AuthenticatedScreen({super.key, this.pin_code_protected = true}) {
    // Brug en mere robust metode til at tjekke terms status
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Vent et øjeblik for at sikre, at context er tilgængelig
      await Future.delayed(const Duration(milliseconds: 100));

      if (_lastKnownContext != null) {
        final currentPath = GoRouter.of(_lastKnownContext!)
            .routerDelegate
            .currentConfiguration
            .fullPath;

        // Kun tjek terms status, hvis vi ikke allerede er på terms-of-service siden
        if (currentPath != '/terms-of-service') {
          await validateTermsStatus(_lastKnownContext);
        } else {}
      } else {}
    });
  }

  static void _navigateToOnboarding(BuildContext context) {
    _lastKnownContext = context;
    GoRouter.of(context).go('/onboarding/begin');
  }

  static void _navigateToTerms(BuildContext context) {
    _lastKnownContext = context;
    try {
      context.go(RoutePaths.termsOfService);
    } catch (e) {
      try {
        GoRouter.of(context).go(RoutePaths.termsOfService);
      } catch (e) {}
    }
  }

  static Future<T> create<T extends AuthenticatedScreen>(T screen) async {
    // Gør pt ikke noget!
    // Gå til bage til en version før 15 maj 2025, så kan du se hvad koden gjorde.
    return screen;
  }

  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Opdater _lastKnownContext hver gang build bliver kaldt
    _updateLastKnownContext(context);

    // Validate auth session first
    final authValidationResult = validateAuthSession(context, ref);
    if (authValidationResult != null) {
      return authValidationResult;
    }

    // Ekstra sikkerhedsforanstaltning: Tjek terms status direkte i build
    final currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (currentPath != '/terms-of-service') {
      final userExtraAsync = ref.watch(userExtraNotifierProvider);
      if (userExtraAsync.hasValue &&
          userExtraAsync.value?.termsConfirmed == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RoutePaths.termsOfService);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }

    validateSupabaseAuth(context);

    validateSecurityStatus(context, ref, pin_code_protected);

    setupAppStoreReviewer(context, ref);
    addCurrentUserIfNotExists(context, ref);

    // Test om encrypted_masterkey_check_value er korrekt
    // final userExtraAsync = ref.watch(userExtraNotifierProvider);
    // if (userExtraAsync.hasValue) {
    //   final userExtra = userExtraAsync.value;
    //   if (userExtra?.encryptedMasterkeyCheckValue != null) {
    //     context.go(RoutePaths.securityKey);
    //   }
    // }

    // Perform validation for onboarding pages
    if (_onboardingValidatedPages.contains(runtimeType)) {
      final userExtraAsync = ref.watch(userExtraNotifierProvider);

      return userExtraAsync.when(
        loading: () {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stack) {
          return const Scaffold(
            body: Center(
              child: Text('Error loading user data'),
            ),
          );
        },
        data: (userExtra) {
          if (userExtra?.onboarding == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToOnboarding(context);
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // // Add security validation here
          // if (_onboardingValidatedPages.contains(runtimeType)) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     validateSecurityStatus(context, ref);
          //   });
          // }

          final auth = ref.watch(authenticatedStateProvider);
          return buildAuthenticatedWidget(context, ref, auth);
        },
      );
    }

    final auth = ref.watch(authenticatedStateProvider);
    return buildAuthenticatedWidget(context, ref, auth);
  }

  // Sikrer at _lastKnownContext altid er opdateret og gyldig
  static void _updateLastKnownContext(BuildContext context) {
    if (context.mounted) {
      _lastKnownContext = context;
    }
  }
}
