import '../../exports.dart';
import '../../features/route_explorer/route_explorer_routes.dart';
import '../../screens/authenticated/test/citron.dart';
import '../../screens/authenticated/test/fredag.dart';
import '../../screens/authenticated/web/web_code.dart';
import '../../screens/authenticated/phone_code/phone_code_screen.dart';
import '../../screens/authenticated/phone_code/phone_code_history_screen.dart';
import '../../screens/authenticated/text_code/text_code_screen.dart';
import '../../screens/authenticated/pin_protected/phone_numbers.dart';

import '../../screens/unauthenticated/auth/login_magic_link.dart';
import '../../screens/unauthenticated/auth/login_email_password.dart';
import '../../screens/unauthenticated/auth/forgot_password.dart';
import '../../screens/unauthenticated/auth/reset_password.dart';
import '../../screens/unauthenticated/auth/password_reset_success.dart';
import '../../screens/unauthenticated/auth/password_reset_error.dart';
import '../../screens/authenticated/pin_protected/update_security_key.dart';

class RoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const loginMagicLink = '/login/magic-link';
  static const loginEmailPassword = '/login/email-password';
  static const forgotPassword = '/login/forgot-password';
  static const resetPassword = '/reset-password';
  static const passwordResetSuccess = '/password-reset-success';
  static const passwordResetError = '/password-reset-error';
  static const checkEmail = '/login_check_email';
  static const home = '/home';
  static const second = '/second';
  static const confirm = '/confirm';
  static const profile = '/profile';
  static const contacts = '/contacts';
  static const demo = '/demo';
  static const authCallback = '/auth-callback';
  static const termsOfService = '/terms-of-service';
  static const contactVerification = '/contact-verification';
  static const settings = '/settings';
  static const connect = '/connect';
  static const level1CreateOrScanQr = '/connect/level1';
  static const level3LinkGenerator = '/connect/level3';
  static const personalInfo = '/onboarding/personal-info';
  static const createPin = '/onboarding/create-pin';
  static const confirmPin = '/onboarding/confirm-pin';
  static const phoneNumber = '/onboarding/phone-number';
  static const profileImage = '/onboarding/profile-image';
  static const onboardingBegin = '/onboarding/begin';
  static const onboardingComplete = '/onboarding/complete';
  static const testForm = '/test/form';
  static const testResult = '/test/result';
  static const swipeTest = '/test/swipe';
  static const banan = '/test/banan';
  static const citron = '/test/citron';
  static const fredag = '/test/fredag';
  static const profileEdit = '/profile/edit';
  static const securityKey = '/security-key';
  static const changePinCode = '/change-pin-code';
  static const updateSecurityKey = '/update-security-key';
  static const webCode = '/web-code';
  static const level1QrCodeCreator = '/connect/level1/qr-code';
  static const scanQrCode = '/connect/level1/scan-qr-code';
  static const invitation = '/invitation';
  static const invitationLevel1 = '/invitation/level1';
  static const level3ConfirmConnection = '/connect/level3/confirm-connection';
  static const level1ConfirmConnection = '/connect/level1/confirm-connection';
  static const enterPincode = '/security/enter-pincode';
  static const qrCodeResult = '/qr';
  static const qrCodeScanning = '/qr/scan';
  static const maintenance = '/system-status/maintenance';
  static const updateApp = '/system-status/update-app';
  static const invalidSecureKey = '/system-status/invalid-secure-key';
  static const routeExplorer = RouteExplorerRoutes.routeExplorer;
  static const phoneCode = '/phone-code';
  static const phoneCodeHistory = '/phone-code/history';
  static const textCode = '/text-code';
  static const phoneNumbers = '/phone-numbers';
  static const deleteAccount = '/delete-account';
  static const noConnection = '/no-connection';
}

/// Skifter side uden animation
CustomTransitionPage<void> _buildPageWithTransition({
  required LocalKey key,
  required Widget child,
}) {
  final log = scopedLogger(LogCategory.other);
  final startTime = DateTime.now();

  log('🔀 [app_router.dart::_buildPageWithTransition] Building page transition');
  log('   - Key: ${key.runtimeType}');
  log('   - Child widget: ${child.runtimeType}');
  log('   - Start time: ${startTime.toIso8601String()}');

  final page = CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('✅ [app_router.dart::_buildPageWithTransition] Page transition built successfully');
      log('   - Build duration: ${duration.inMilliseconds}ms');
      return child;
    },
  );

  return page;
}

bool _isInitialLoad = true;

/// Helper til at bygge en autentificeret skærm med FutureBuilder og create()-metoden
Widget _buildAuthenticatedPage<T extends AuthenticatedScreen>({
  required Future<T> Function() createFunction,
}) {
  final log = scopedLogger(LogCategory.other);
  final startTime = DateTime.now();

  log('🔐 [app_router.dart::_buildAuthenticatedPage] Building authenticated page');
  log('   - Screen type: $T');
  log('   - Start time: ${startTime.toIso8601String()}');

  return FutureBuilder<T>(
    future: createFunction(),
    builder: (context, snapshot) {
      final buildTime = DateTime.now();
      final buildDuration = buildTime.difference(startTime);

      if (snapshot.connectionState == ConnectionState.waiting) {
        log('⏳ [app_router.dart::_buildAuthenticatedPage] Screen creation in progress');
        log('   - Wait duration: ${buildDuration.inMilliseconds}ms');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (snapshot.hasError) {
        log('❌ [app_router.dart::_buildAuthenticatedPage] Error creating authenticated screen');
        log('   - Error: ${snapshot.error}');
        log('   - Stack trace: ${snapshot.stackTrace}');
        return Scaffold(
          body: Center(
            child: Text('Error loading screen: ${snapshot.error}'),
          ),
        );
      }

      if (snapshot.hasData) {
        log('✅ [app_router.dart::_buildAuthenticatedPage] Authenticated page built successfully');
        log('   - Screen type: $T');
        log('   - Total build duration: ${buildDuration.inMilliseconds}ms');
        return snapshot.data!;
      }

      log('⚠️ [app_router.dart::_buildAuthenticatedPage] Unexpected state in FutureBuilder');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

final appRouter = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);
  final userExtra = ref.read(userExtraNotifierProvider);
  final log = scopedLogger(LogCategory.other);

  log('🚀 [app_router.dart::appRouter] Initializing GoRouter');
  log('   - Auth state: ${isLoggedIn ? "AUTHENTICATED" : "UNAUTHENTICATED"}');
  log('   - Initial location: ${RoutePaths.splash}');

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final redirectStartTime = DateTime.now();

      log('\n🛡️ [app_router.dart::redirect] === ROUTER SECURITY CHECK START ===');
      log('   - Timestamp: ${redirectStartTime.toIso8601String()}');
      log('   - Current auth state: ${isLoggedIn ? "✅ LOGGED IN" : "❌ NOT LOGGED IN"}');
      log('   - Requested location: ${state.location}');
      log('   - Query parameters: ${state.queryParameters}');
      log('   - Path parameters: ${state.pathParameters}');
      log('   - Extra data: ${state.extra?.runtimeType ?? "null"}');
      log('   - Initial load flag: $_isInitialLoad');
      log('   - DEBUG: Path: ${state.path}');

      // Extra logging for reset password debugging
      log('🔍 [RESET PASSWORD DEBUG] Checking if this is reset password related:');
      log('   - Is location /reset-password? ${state.location == RoutePaths.resetPassword}');
      log('   - Has token param? ${state.queryParameters.containsKey('token')}');
      log('   - Has code param? ${state.queryParameters.containsKey('code')}');
      log('   - Has type param? ${state.queryParameters.containsKey('type')}');
      log('   - Has error param? ${state.queryParameters.containsKey('error')}');

      // Save for later
      // TERMS OF SERVICE CHECK - First priority
      // if (isLoggedIn) {
      //   log('🔍 🔍 🔍 🔍 🔍 Bruger er logget ind.');
      //   final isTermsConfirmed = userExtra.valueOrNull?.termsConfirmed ?? false;
      //   log(
      //       'Terms status: ${isTermsConfirmed ? "ACCEPTED" : "NOT ACCEPTED"}');

      //   if (!isTermsConfirmed && state.location != RoutePaths.termsOfService) {
      //     log('❌ Terms not accepted - forcing terms page');
      //     log('   - Current location: ${state.location}');
      //     log('   - Redirecting to: ${RoutePaths.termsOfService}');
      //     return RoutePaths.termsOfService;
      //   }
      // }

      // Handle auth callback errors - BUT exclude reset-password route
      final queryParams = state.queryParameters;
      if (queryParams.containsKey('error') && state.location != RoutePaths.resetPassword) {
        log('🚨 [app_router.dart::redirect] Auth callback error detected');
        log('   - Error: ${queryParams['error']}');
        log('   - Error description: ${queryParams['error_description']}');
        log('   - Redirecting to login screen');
        return RoutePaths.login;
      } else if (queryParams.containsKey('error') && state.location == RoutePaths.resetPassword) {
        log('🔍 [RESET PASSWORD DEBUG] Error detected but allowing reset-password route to handle it');
        log('   - Error: ${queryParams['error']}');
        log('   - Error description: ${queryParams['error_description']}');
      }

      // Handle successful auth callback
      if (state.location.contains('auth-callback') || state.location.contains('login/auth-callback')) {
        log('🔐 [app_router.dart::redirect] Auth callback success detected');
        log('   - Original location: ${state.location}');

        // Check if this is a reset password callback
        final isResetPasswordCallback = _isResetPasswordCallback(state.location);

        if (isResetPasswordCallback) {
          log('   - Detected reset password callback, redirecting to reset-password');
          // Forward query parameters to reset password screen
          final uri = Uri.parse(state.location);
          final queryParams = uri.queryParameters;
          if (queryParams.isNotEmpty) {
            final queryString = Uri(queryParameters: queryParams).query;
            log('   - Forwarding query parameters: $queryString');
            return '${RoutePaths.resetPassword}?$queryString';
          }
          return RoutePaths.resetPassword;
        } else {
          log('   - Detected normal auth callback, redirecting to home');
          return RoutePaths.home;
        }
      }

      // Vis kun splash screen ved første app load
      if (state.location == RoutePaths.splash && _isInitialLoad) {
        log('🚀 [app_router.dart::redirect] Initial app load detected');
        log('   - Showing splash screen');
        log('   - Setting initial load flag to false');
        _isInitialLoad = false;
        return null;
      }

      // Hvis brugeren lige er blevet logget ind via deep link,
      // skal de sendes til home
      if (state.location == RoutePaths.splash && isLoggedIn) {
        final deepLinkHandled = ref.read(authProvider.notifier).wasDeepLinkHandled;

        if (deepLinkHandled) {
          log('   - Deep link auth detected, redirecting to home');
          return RoutePaths.home;
        }
      }

      // For alle andre requests
      if (state.location == RoutePaths.splash) {
        log('📱 [app_router.dart::redirect] Splash screen request processing');
        final destination = isLoggedIn ? RoutePaths.home : RoutePaths.login;
        log('   - Auth-based destination: $destination');
        log('   - Reason: ${isLoggedIn ? "User authenticated" : "User not authenticated"}');
        return destination;
      }

      // List of protected routes
      final protectedRoutes = [
        RoutePaths.home,
        RoutePaths.second,
        RoutePaths.profile,
        RoutePaths.contacts,
        RoutePaths.demo,
        RoutePaths.termsOfService,
        RoutePaths.connect,
        RoutePaths.securityKey,
        RoutePaths.banan,
      ];

      // Beskyt auth-krævende routes
      if (isLoggedIn == false && protectedRoutes.contains(state.location)) {
        log('🔒 [app_router.dart::redirect] Protected route access attempt');
        log('   - Requested route: ${state.location}');
        log('   - Auth status: NOT LOGGED IN');
        log('   - Action: Redirecting to login');
        return RoutePaths.login;
      }

      // Extra logging for reset password cases
      log('🔍 [RESET PASSWORD DEBUG] Checking final redirect decision:');
      log('   - Is protected route? ${protectedRoutes.contains(state.location)}');
      log('   - Is reset password route? ${state.location == RoutePaths.resetPassword}');
      log('   - Will continue to route: ${state.location}');

      final redirectEndTime = DateTime.now();
      final redirectDuration = redirectEndTime.difference(redirectStartTime);

      log('✅ [app_router.dart::redirect] No redirect needed');
      log('   - Final destination: ${state.location}');
      log('   - Redirect check duration: ${redirectDuration.inMilliseconds}ms');
      log('🛡️ [app_router.dart::redirect] === ROUTER SECURITY CHECK END ===\n');

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.noConnection,
        pageBuilder: (context, state) {
          log('📵 [app_router.dart] Building NoConnectionScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: NoConnectionScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) {
          log('🎬 [app_router.dart] Building SplashScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const SplashScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) {
          log('🔑 [app_router.dart] Building LoginScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.loginMagicLink,
        pageBuilder: (context, state) {
          log('✨ [app_router.dart] Building LoginMagicLinkScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginMagicLinkScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.loginEmailPassword,
        pageBuilder: (context, state) {
          log('📧 [app_router.dart] Building LoginEmailPasswordScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginEmailPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        pageBuilder: (context, state) {
          log('🔐 [app_router.dart] Building ForgotPasswordScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        pageBuilder: (context, state) {
          log('🔒 [app_router.dart] Building ResetPasswordScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const ResetPasswordScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.passwordResetSuccess,
        pageBuilder: (context, state) {
          log('✅ [app_router.dart] Building PasswordResetSuccessScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const PasswordResetSuccessScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.passwordResetError,
        pageBuilder: (context, state) {
          log('❌ [app_router.dart] Building PasswordResetErrorScreen route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const PasswordResetErrorScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.checkEmail,
        pageBuilder: (context, state) {
          final email = state.extra as String? ?? '';
          log('📬 [app_router.dart] Building CheckEmailScreen route');
          log('   - Email parameter: ${email.isNotEmpty ? "provided" : "empty"}');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: CheckEmailScreen(
              email: email,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.home,
        pageBuilder: (context, state) {
          log('🏠 [app_router.dart] Building HomePage route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: HomePage.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.second,
        pageBuilder: (context, state) {
          log('2️⃣ [app_router.dart] Building SecondPage route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: SecondPage.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.confirm,
        pageBuilder: (context, state) {
          log('✅ [app_router.dart] Building LoginLandingPage route');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginLandingPage(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        pageBuilder: (context, state) {
          log('👤 [app_router.dart] Building ProfilePage route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: ProfilePage.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.contacts,
        pageBuilder: (context, state) {
          log('📞 [app_router.dart] Building ContactsScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: ContactsScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.phoneCode,
        pageBuilder: (context, state) {
          log('📱 [app_router.dart] Building PhoneCodeScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: PhoneCodeScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.phoneCodeHistory,
        pageBuilder: (context, state) {
          log('📝 [app_router.dart] Building PhoneCodeHistoryScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: PhoneCodeHistoryScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.textCode,
        pageBuilder: (context, state) {
          log('💬 [app_router.dart] Building TextCodeScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: TextCodeScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.phoneNumbers,
        pageBuilder: (context, state) {
          log('📞 [app_router.dart] Building PhoneNumbersScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: PhoneNumbersScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.demo,
        pageBuilder: (context, state) {
          log('🎮 [app_router.dart] Building DemoScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: DemoScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.authCallback,
        pageBuilder: (context, state) {
          log('🔄 [app_router.dart] Building AuthCallbackScreen route');
          log('   - Query params: ${state.queryParameters}');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: const AuthCallbackScreen(),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.termsOfService,
        pageBuilder: (context, state) {
          log('📄 [app_router.dart] Building TermsOfServiceScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: TermsOfServiceScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.personalInfo,
        pageBuilder: (context, state) {
          log('ℹ️ [app_router.dart] Building OnboardingProfileScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: OnboardingProfileScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.createPin,
        pageBuilder: (context, state) {
          log('🔢 [app_router.dart] Building OnboardingPINScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: OnboardingPINScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.confirmPin,
        name: 'confirm-pin',
        pageBuilder: (context, state) {
          final pin = state.extra as String? ?? '';
          log('🔢 [app_router.dart] Building OnboardingPINConfirmScreen route (authenticated)');
          log('   - PIN parameter: ${pin.isNotEmpty ? "provided" : "empty"}');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: () => OnboardingPINConfirmScreen.create(pinToConfirm: pin),
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.phoneNumber,
        pageBuilder: (context, state) {
          log('📱 [app_router.dart] Building OnboardingPhoneNumberScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: OnboardingPhoneNumberScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profileImage,
        pageBuilder: (context, state) {
          log('🖼️ [app_router.dart] Building OnboardingProfileImageScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: OnboardingProfileImageScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: '/contact-verification/:contactId',
        pageBuilder: (context, state) {
          final contactId = state.pathParameters['contactId']!;
          log('📋 [app_router.dart] Building ContactVerificationScreen route (authenticated)');
          log('   - Contact ID: $contactId');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: () => ContactVerificationScreen.create(contactId: contactId),
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (context, state) {
          log('⚙️ [app_router.dart] Building SettingsScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: SettingsScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.deleteAccount,
        pageBuilder: (context, state) {
          log('🗑️ [app_router.dart] Building DeleteAccountScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: DeleteAccountScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.connect,
        pageBuilder: (context, state) {
          log('🔗 [app_router.dart] Building ConnectScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: ConnectScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.onboardingBegin,
        pageBuilder: (context, state) {
          log('🚀 [app_router.dart] Building OnboardingBeginScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: OnboardingBeginScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.onboardingComplete,
        pageBuilder: (context, state) {
          log('🎉 [app_router.dart] Building OnboardingComplete route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: OnboardingCompleteScreen.create, // Rettet navn
            ),
          );
        },
      ),
      // GoRoute(
      //   path: RoutePaths.testForm,
      //   pageBuilder: (context, state) => _buildPageWithTransition(
      //     key: state.pageKey,
      //     child: FormScreen(),
      //   ),
      // ),
      // GoRoute(
      //   path: RoutePaths.testResult,
      //   pageBuilder: (context, state) => _buildPageWithTransition(
      //     key: state.pageKey,
      //     child: ResultScreen(formData: state.extra as Map<String, String>),
      //   ),
      // ),
      GoRoute(
        path: RoutePaths.profileEdit,
        pageBuilder: (context, state) {
          log('✏️ [app_router.dart] Building ProfileEditScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: ProfileEditScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.securityKey,
        pageBuilder: (context, state) {
          log('🔐 [app_router.dart] Building SecurityKeyScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: SecurityKeyScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.changePinCode,
        pageBuilder: (context, state) {
          log('🔢 [app_router.dart] Building ChangePinCodeScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: ChangePinCodeScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.updateSecurityKey,
        pageBuilder: (context, state) {
          log('🔑 [app_router.dart] Building UpdateSecurityKeyScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: UpdateSecurityKeyScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.webCode,
        pageBuilder: (context, state) {
          log('🌐 [app_router.dart] Building WebCodeScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: WebCodeScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.level1CreateOrScanQr,
        pageBuilder: (context, state) {
          log('🔗1️⃣ [app_router.dart] Building Level1CreateOrScanQrSelectorScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: Level1CreateOrScanQrSelectorScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.level3LinkGenerator,
        pageBuilder: (context, state) {
          log('🔗3️⃣ [app_router.dart] Building Level3LinkGeneratorScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: Level3LinkGeneratorScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.level1QrCodeCreator,
        pageBuilder: (context, state) {
          log('📱 [app_router.dart] Building Level1QrCodeCreator route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: Level1QrCodeCreator.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.scanQrCode,
        pageBuilder: (context, state) {
          log('📷 [app_router.dart] Building Level1QrCodeScannerScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: Level1QrCodeScannerScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.level3ConfirmConnection,
        pageBuilder: (context, state) {
          log('✅ [app_router.dart] Building Level3ConfirmConnectionScreen route (authenticated)');
          log('   - Query params: ${state.queryParameters}');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: Level3ConfirmConnectionScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.level1ConfirmConnection,
        pageBuilder: (context, state) {
          log('✅1️⃣ [app_router.dart] Building Level1ConfirmConnectionScreen route (authenticated)');
          log('   - Query params: ${state.queryParameters}');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: Level1ConfirmConnectionScreen.create,
            ),
          );
        },
      ),
      // GoRoute(
      //     path: RoutePaths.confirmConnectionLevel1,
      //     redirect: (context, state) {
      //       final id = state.queryParameters['invite'];
      //       final key = state.queryParameters['key'];
      //       if (id != null) {
      //         final encodedKey = key != null ? Uri.encodeComponent(key) : '';
      //         return '${RoutePaths.confirmConnection}?invite=$id${encodedKey.isNotEmpty ? "&key=$encodedKey" : ""}';
      //       }
      //       return RoutePaths.home;
      //     }),
      // Handle invitation links directly
      GoRoute(
        path: RoutePaths.invitationLevel1,
        redirect: (context, state) {
          final id = state.queryParameters['invite'];
          final key = state.queryParameters['key'];
          log('📧 [app_router.dart] Processing invitation level 1 redirect');
          log('   - Invite ID: ${id ?? "null"}');
          log('   - Key present: ${key != null}');

          if (id != null) {
            final encodedKey = key != null ? Uri.encodeComponent(key) : '';
            final redirectUrl = '${RoutePaths.level1ConfirmConnection}?invite=$id${encodedKey.isNotEmpty ? "&key=$encodedKey" : ""}';
            log('   - Redirecting to: $redirectUrl');
            return redirectUrl;
          }
          log('   - No invite ID found, redirecting to home');
          return RoutePaths.home;
        },
      ),
      GoRoute(
        path: RoutePaths.invitation,
        redirect: (context, state) {
          final id = state.queryParameters['invite'];
          final key = state.queryParameters['key'];
          log('📧 [app_router.dart] Processing invitation redirect');
          log('   - Invite ID: ${id ?? "null"}');
          log('   - Key present: ${key != null}');

          if (id != null) {
            final encodedKey = key != null ? Uri.encodeComponent(key) : '';
            final redirectUrl = '${RoutePaths.level3ConfirmConnection}?invite=$id${encodedKey.isNotEmpty ? "&key=$encodedKey" : ""}';
            log('   - Redirecting to: $redirectUrl');
            return redirectUrl;
          }
          log('   - No invite ID found, redirecting to home');
          return RoutePaths.home;
        },
      ),
      GoRoute(
        path: RoutePaths.enterPincode,
        pageBuilder: (context, state) {
          log('🔢 [app_router.dart] Building EnterPincodePage route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: EnterPincodePage.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.qrCodeResult,
        pageBuilder: (context, state) {
          final qrCode = state.queryParameters['qr_code'];
          log('📱 [app_router.dart] Building QrCodeResultScreen route (authenticated)');
          log('   - QR Code parameter: ${qrCode != null ? "provided" : "null"}');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: () => QrCodeResultScreen.create(qrCode: qrCode),
            ),
          );
        },
      ),

      GoRoute(
        path: RoutePaths.qrCodeScanning,
        pageBuilder: (context, state) {
          log('📷 [app_router.dart] Building QrCodeScanningScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: QrCodeScanningScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.maintenance,
        pageBuilder: (context, state) {
          log('🔧 [app_router.dart] Building MaintenanceScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: MaintenanceScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.updateApp,
        pageBuilder: (context, state) {
          log('📱 [app_router.dart] Building UpdateAppScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: UpdateAppScreen.create,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.invalidSecureKey,
        pageBuilder: (context, state) {
          log('🔑 [app_router.dart] Building InvalidSecureKeyScreen route (authenticated)');
          return _buildPageWithTransition(
            key: state.pageKey,
            child: _buildAuthenticatedPage(
              createFunction: InvalidSecureKeyScreen.create,
            ),
          );
        },
      ),
      RouteExplorerRoutes.getRoute(),
    ],
  );
});

/// Helper function to determine if an auth callback is for password reset
bool _isResetPasswordCallback(String location) {
  final log = scopedLogger(LogCategory.other);

  // Parse the URI to extract query parameters
  final uri = Uri.parse(location);
  final queryParams = uri.queryParameters;

  log('🔍 [_isResetPasswordCallback] Analyzing callback:');
  log('   - Location: $location');
  log('   - Query params: $queryParams');

  // Check for reset password indicators
  final hasToken = queryParams.containsKey('token');
  final hasType = queryParams.containsKey('type');
  final typeValue = queryParams['type'];
  final hasCode = queryParams.containsKey('code');

  // Reset password typically has token and type=magic-link, but NOT code
  // Regular login typically has code parameter
  final isResetPassword = hasToken && hasType && typeValue == 'magic-link' && !hasCode;

  log('   - Has token: $hasToken');
  log('   - Has type: $hasType (value: $typeValue)');
  log('   - Has code: $hasCode');
  log('   - Is reset password: $isResetPassword');

  return isResetPassword;
}

// Created: 2024-12-19 10:45:00
