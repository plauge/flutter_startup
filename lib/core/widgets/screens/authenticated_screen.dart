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
import '../../../screens/authenticated/pin_protected/demo.dart';
import '../../../screens/authenticated/pin_protected/profile.dart';
import '../../../screens/authenticated/pin_protected/contacts.dart';
import '../../../screens/authenticated/pin_protected/contact_verification.dart';
import 'base_screen.dart';
import 'dart:convert';
import '../../../core/constants/storage_constants.dart';
import '../../../models/user_storage_data.dart';
import '../../../providers/storage/storage_provider.dart';
import '../../../utils/aes_gcm_encryption_utils.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/security_provider.dart';
import '../../../providers/security_validation_provider.dart';
import 'authenticated_screen_helpers/validate_security_status.dart';
import 'authenticated_screen_helpers/add_current_user_if_not_exists.dart';
import 'authenticated_screen_helpers/validate_auth_session.dart';
import 'authenticated_screen_helpers/validate_terms_status.dart';
import 'authenticated_screen_helpers/validate_master_key_status.dart';
import 'authenticated_screen_helpers/user_activity_tracker.dart';
import 'authenticated_screen_helpers/face_id_protection_layer.dart';
import '../../../providers/analytics_provider.dart';

abstract class AuthenticatedScreen extends BaseScreen {
  final _container = ProviderContainer();
  static BuildContext? _lastKnownContext;
  static String? _lastTrackedScreen;

  /// Whether this screen requires PIN code verification
  final bool pin_code_protected;

  /// Whether this screen requires Face ID verification
  final bool face_id_protected;

  static final log = scopedLogger(LogCategory.security);

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
    ConnectScreen,
    Level1QrCodeScannerScreen,
    Level1QrCodeCreator,
    Level1CreateOrScanQrSelectorScreen,
    Level1ConfirmConnectionScreen,
    Level3ConfirmConnectionScreen,
    Level3LinkGeneratorScreen
  ];

  @protected
  AuthenticatedScreen({super.key, this.pin_code_protected = true, this.face_id_protected = false}) {
    // Brug en mere robust metode til at tjekke terms status
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Vent et øjeblik for at sikre, at context er tilgængelig
      await Future.delayed(const Duration(milliseconds: 100));

      if (_lastKnownContext != null) {
        final currentPath = GoRouter.of(_lastKnownContext!).routerDelegate.currentConfiguration.fullPath;

        // Kun tjek terms status, hvis vi ikke allerede er på terms-of-service siden
        if (currentPath != RoutePaths.termsOfService) {
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

  void _trackScreenView(BuildContext context, WidgetRef ref) {
    try {
      final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
      final screenName = runtimeType.toString();

      // Undgå at tracke samme screen flere gange i træk
      if (_lastTrackedScreen == screenName) return;

      _lastTrackedScreen = screenName;

      final analytics = ref.read(analyticsServiceProvider);

      // Automatisk identifikation af bruger
      final currentUser = ref.read(authProvider);
      if (currentUser?.email != null) {
        analytics.identify(currentUser!.email);
      }

      analytics.track('screen_viewed', {
        'screen_name': screenName,
        'screen_path': currentPath,
        'pin_protected': pin_code_protected,
        'face_id_protected': face_id_protected,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      // Analytics fejl påvirker ikke app funktionalitet
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Opdater _lastKnownContext hver gang build bliver kaldt
    _updateLastKnownContext(context);

    Widget _wrapWithGuard(Widget child) => Stack(children: [const SupabaseConnectionGuard(), child]);

    // Track screen view automatisk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackScreenView(context, ref);
    });

    // Determine current path early for guards
    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    // Validate auth session first
    final authValidationResult = validateAuthSession(context, ref);
    if (authValidationResult != null) {
      return _wrapWithGuard(authValidationResult);
    }

    // Ekstra sikkerhedsforanstaltning: Tjek terms status direkte i build
    if (currentPath != RoutePaths.termsOfService) {
      final userExtraAsync = ref.watch(userExtraNotifierProvider);
      if (userExtraAsync.hasValue && userExtraAsync.value?.termsConfirmed == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RoutePaths.termsOfService);
        });
        return _wrapWithGuard(const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ));
      }
    }

    validateSupabaseAuth(context);
    
    // Face ID validation must happen BEFORE PIN code validation
    // If Face ID is required, wrap the child in FaceIdProtectionLayer
    Widget _wrapWithFaceIdIfNeeded(Widget child) {
      final screenName = runtimeType.toString();
      log('_wrapWithFaceIdIfNeeded - lib/core/widgets/screens/authenticated_screen.dart', {
        'screen': screenName,
        'face_id_protected': face_id_protected,
        'pin_code_protected': pin_code_protected,
      });
      
      // ONLY wrap if face_id_protected is EXPLICITLY true
      // Default is false, so if not explicitly set to true, do NOT wrap
      if (!face_id_protected) {
        log('FaceID NOT required - returning child directly - lib/core/widgets/screens/authenticated_screen.dart', {
          'screen': screenName,
        });
        return child;
      }
      
      // Only create FaceIdProtectionLayer if face_id_protected is explicitly true
      log('FaceID REQUIRED - creating FaceIdProtectionLayer - lib/core/widgets/screens/authenticated_screen.dart', {
        'screen': screenName,
      });
      return FaceIdProtectionLayer(
        key: ValueKey('face_id_protection_${screenName}'),
        screenName: screenName,
        child: child,
      );
    }
    
    validateSecurityStatus(context, ref, pin_code_protected);
    setupAppStoreReviewer(context, ref);
    // addCurrentUserIfNotExists(context, ref);
    if (currentPath != RoutePaths.updateSecurityKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await validateMasterKeyStatus(context, ref, pin_code_protected);
      });
    }

    // Perform validation for onboarding pages
    if (_onboardingValidatedPages.contains(runtimeType)) {
      final userExtraAsync = ref.watch(userExtraNotifierProvider);

      return userExtraAsync.when(
        loading: () {
          return _wrapWithGuard(const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ));
        },
        error: (error, stack) {
          return _wrapWithGuard(const Scaffold(
            body: Center(
              child: Text('Error loading user data'),
            ),
          ));
        },
        data: (userExtra) {
          if (userExtra?.onboarding == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToOnboarding(context);
            });
            return _wrapWithGuard(const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ));
          }

          // // Add security validation here
          // if (_onboardingValidatedPages.contains(runtimeType)) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     validateSecurityStatus(context, ref);
          //   });
          // }

          final auth = ref.watch(authenticatedStateProvider);
          return _wrapWithGuard(
            _wrapWithFaceIdIfNeeded(
            UserActivityTracker(
              child: buildAuthenticatedWidget(context, ref, auth),
              ),
            ),
          );
        },
      );
    }

    final auth = ref.watch(authenticatedStateProvider);

    //if (currentPath != RoutePaths.enterPincode) {
    // Kald updateUserExtraLatestLoad med 1 sekunds delay som det sidste
    if (pin_code_protected) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 3));
        try {
          final securityVerification = ref.read(securityVerificationProvider.notifier);
          await securityVerification.updateUserExtraLatestLoad();
        } catch (e) {
          // Stille fejl - vi logger ikke da det ikke er kritisk
        }
      });
    }
    //}

    return _wrapWithGuard(
      _wrapWithFaceIdIfNeeded(
      UserActivityTracker(
        child: buildAuthenticatedWidget(context, ref, auth),
        ),
      ),
    );
  }

  // Sikrer at _lastKnownContext altid er opdateret og gyldig
  static void _updateLastKnownContext(BuildContext context) {
    if (context.mounted) {
      _lastKnownContext = context;
    }
  }
}
