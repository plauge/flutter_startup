import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_startup/exports.dart';
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
import 'dart:convert';
import '../../../core/constants/storage_constants.dart';
import '../../../models/user_storage_data.dart';
import '../../../providers/storage/storage_provider.dart';
import '../../../utils/aes_gcm_encryption_utils.dart';

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
          await _validateTermsStatus();
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

  Future<void> _validateTermsStatus() async {
    print('BEGIN VALIDATING TERMS');
    print('🔍🔍🔍🔍/////// Validating page: $runtimeType');

    try {
      final userExtraAsync =
          await _container.read(userExtraNotifierProvider.future);
      print('🔍 UserExtra data: $userExtraAsync');
      if (userExtraAsync?.termsConfirmed != true) {
        print('⚠️ Terms not confirmed - redirecting to terms');
        if (_lastKnownContext != null) {
          print('🔄 Navigating to terms page');
          _navigateToTerms(_lastKnownContext!);
        } else {
          print('❌ No context available for navigation');
        }
      } else {
        print('✅ Terms check passed - staying on page');
      }
    } catch (e) {
      print('❌ Error reading UserExtra: $e');
    }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _lastKnownContext = context;
    print('🏗️ BUILD: Loading screen: ${runtimeType.toString()}');

    // Add user storage data if needed
    if (_onboardingValidatedPages.contains(runtimeType)) {
      _addCurrentUserIfNotExists(ref);
    }

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
