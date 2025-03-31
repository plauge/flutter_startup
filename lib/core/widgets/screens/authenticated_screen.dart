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
    print('🏗️ AuthenticatedScreen constructor called for: $runtimeType');

    // Brug en mere robust metode til at tjekke terms status
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🔄 PostFrameCallback triggered for: $runtimeType');

      // Vent et øjeblik for at sikre, at context er tilgængelig
      await Future.delayed(const Duration(milliseconds: 100));

      if (_lastKnownContext != null) {
        final currentPath = GoRouter.of(_lastKnownContext!)
            .routerDelegate
            .currentConfiguration
            .fullPath;
        print('🔍 Current path in PostFrameCallback: $currentPath');

        // Kun tjek terms status, hvis vi ikke allerede er på terms-of-service siden
        if (currentPath != '/terms-of-service') {
          print('🔍 Not on terms page, checking terms status');
          await _validateTermsStatus();
        } else {
          print('✅ Already on terms page, skipping terms check');
        }
      } else {
        print('❌ _lastKnownContext is null in PostFrameCallback');
      }
    });
  }

  static void _navigateToOnboarding(BuildContext context) {
    _lastKnownContext = context;
    GoRouter.of(context).go('/onboarding/begin');
  }

  static void _navigateToTerms(BuildContext context) {
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

  Future<void> _validateTermsStatus() async {
    print('BEGIN VALIDATING TERMS');
    print('🔍🔍🔍🔍/////// Validating page: $runtimeType');

    try {
      print('🔍 Getting current user...');
      final user = Supabase.instance.client.auth.currentUser;
      print('✅ Current user found: ${user?.email}');

      print('🔄 Attempting to read userExtraNotifierProvider.future...');
      final userExtraAsync =
          await _container.read(userExtraNotifierProvider.future);
      print('✅ Successfully read userExtraNotifierProvider.future');
      print('🔍 UserExtra data: $userExtraAsync');
      print('🔍 Terms confirmed status: ${userExtraAsync?.termsConfirmed}');

      if (userExtraAsync?.termsConfirmed != true) {
        print('⚠️ Terms not confirmed - redirecting to terms');
        if (_lastKnownContext != null) {
          print(
              '✅ _lastKnownContext is available: ${_lastKnownContext.hashCode}');
          print('🔄 Navigating to terms page');

          // Brug en mere direkte tilgang til navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🔄 Inside PostFrameCallback for terms navigation');
            try {
              if (_lastKnownContext!.mounted) {
                print('✅ Context is mounted, navigating to terms page');
                _lastKnownContext!.go(RoutePaths.termsOfService);
                print('✅ Navigation to terms page completed via context.go()');
              } else {
                print('❌ Context is not mounted, trying GoRouter.of()');
                GoRouter.of(_lastKnownContext!).go(RoutePaths.termsOfService);
                print('✅ Navigation to terms page completed via GoRouter.of()');
              }
            } catch (e) {
              print('❌ Error during navigation: $e');
              try {
                print('🔄 Trying alternative navigation method');
                Navigator.of(_lastKnownContext!).pushNamedAndRemoveUntil(
                  RoutePaths.termsOfService,
                  (route) => false,
                );
                print('✅ Navigation to terms page completed via Navigator');
              } catch (e) {
                print('❌ All navigation methods failed: $e');
              }
            }
          });
        } else {
          print('❌ No context available for navigation');
        }
      } else {
        print('✅ Terms check passed - staying on page');
      }
    } catch (e, stackTrace) {
      print('❌ Error reading UserExtra: $e');
      print('❌ Stack trace: $stackTrace');
    }
    print('🏁 _validateTermsStatus completed');
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

  Future<void> _addCurrentUserIfNotExists(WidgetRef ref) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final storage = ref.read(storageProvider.notifier);
    final existingUser = await storage.getUserStorageDataByEmail(user.email);

    if (existingUser != null) {
      return;
    }

    final newUserData = UserStorageData(
      email: user.email,
      token: AESGCMEncryptionUtils.generateSecureToken(),
      testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
    );

    final currentData = await storage.getUserStorageData();
    final updatedData = [...currentData, newUserData];
    await storage.saveString(
      kUserStorageKey,
      jsonEncode(updatedData.map((e) => e.toJson()).toList()),
      secure: true,
    );
  }

  Widget? _validateAuthSession(BuildContext context, WidgetRef ref) {
    final authValidation = ref.watch(authValidationProvider);
    return authValidation.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        print('🚨 Auth validation failed: $error');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authProvider.notifier).signOut();
          GoRouter.of(context).go('/login');
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      data: (response) {
        if (response.statusCode != 200) {
          print(
              '🚨 Auth validation failed: Invalid status code ${response.statusCode}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authProvider.notifier).signOut();
            GoRouter.of(context).go('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return null;
      },
    );
  }

  Future<void> validateSecurityStatus(
      BuildContext context, WidgetRef ref) async {
    print('🔒 BEGIN: Security validation for ${runtimeType.toString()}');
    try {
      print('📡 Calling security verification with code 101');
      final response = await ref
          .read(securityVerificationProvider.notifier)
          .doCaretaking('101');

      if (response.isEmpty) {
        print('⚠️ ERROR: Empty response from security validation');
        throw SecurityValidationError('No response from security validation');
      }

      print('📥 Received security response: $response');
      final firstResponse = response.first;
      final statusCode = firstResponse['status_code'] as int;
      print('🔍 Status code: $statusCode');

      final data = firstResponse['data'] as Map<String, dynamic>;
      final payload = data['payload'] as String;
      print('📦 Security payload received: $payload');

      switch (payload.toLowerCase()) {
        case 'pin_code_login':
          print(
              '🔐 User needs PIN code login - redirecting to PIN code screen');
          if (context.mounted) {
            print('🔐 Redirecting to PIN code screen');
            context.go(RoutePaths.enterPincode);
          } else {
            print('❌ Context not mounted - cannot redirect to PIN code screen');
          }
          break;

        case 'needs_verification':
          print('✋ User needs verification - redirecting to demo screen');
          if (context.mounted) {
            context.go(RoutePaths.home);
          }
          break;

        case 'maintenance_mode':
          print('✋ maintenance_mode - redirecting to maintenance_mode');
          if (context.mounted) {
            context.go(RoutePaths.maintenance);
          }
          break;

        case 'minimum_required_version':
          print('✋ minimum_required_version - redirecting to update_app');
          if (context.mounted) {
            context.go(RoutePaths.updateApp);
          }
          break;

        case 'expired':
          print('⏰ Session expired - logging out user');
          if (context.mounted) {
            // ref.read(authProvider.notifier).signOut();
            // context.go(RoutePaths.login);
          }
          break;

        case 'ok':
          print('✅ Security validation passed successfully');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
          break;

        default:
          print('❓ Unknown security payload received: $payload');
          throw SecurityValidationError('Unknown security payload: $payload');
      }
    } catch (e, stackTrace) {
      print('🚨 Security validation error: $e');
      print('📚 Stack trace: $stackTrace');
      // Remove the logout logic here since we want to handle 401 properly
      // if (context.mounted) {
      //   print('🚪 Logging out user due to security error');
      //   //ref.read(authProvider.notifier).signOut();
      //   //context.go(RoutePaths.login);
      // }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Opdater _lastKnownContext hver gang build bliver kaldt
    _updateLastKnownContext(context);

    print('🏗️ BUILD: Loading screen: ${runtimeType.toString()}');
    print('🔍 _lastKnownContext set to: ${context.hashCode}');

    // Validate auth session first
    final authValidationResult = _validateAuthSession(context, ref);
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
        print(
            '⚠️ Terms not confirmed detected in build - redirecting to terms');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('🔄 Navigating to terms page from build');
          context.go(RoutePaths.termsOfService);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }

    // Add user storage data if needed
    if (_onboardingValidatedPages.contains(runtimeType)) {
      _addCurrentUserIfNotExists(ref);
    }

    // if (_onboardingValidatedPages.contains(runtimeType)) {
    //   validateSecurityStatus(context, ref);
    // }

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

          // Add security validation here
          if (_onboardingValidatedPages.contains(runtimeType)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              validateSecurityStatus(context, ref);
            });
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

  // Sikrer at _lastKnownContext altid er opdateret og gyldig
  static void _updateLastKnownContext(BuildContext context) {
    if (context.mounted) {
      _lastKnownContext = context;
      print('✅ _lastKnownContext updated to: ${context.hashCode}');
    }
  }
}
