import '../../exports.dart';

class RoutePaths {
  static const splash = '/';
  static const login = '/login';
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
  static const connectLevel1 = '/connect/level1';
  static const connectLevel3 = '/connect/level3';
  static const personalInfo = '/onboarding/personal-info';
  static const createPin = '/onboarding/create-pin';
  static const confirmPin = '/onboarding/confirm-pin';
  static const profileImage = '/onboarding/profile-image';
  static const onboardingBegin = '/onboarding/begin';
  static const onboardingComplete = '/onboarding/complete';
  static const testForm = '/test/form';
  static const testResult = '/test/result';
  static const swipeTest = '/test/swipe';
  static const profileEdit = '/profile/edit';
  static const securityKey = '/security-key';
  static const qrCode = '/connect/level1/qr-code';
  static const scanQrCode = '/connect/level1/scan-qr-code';
  static const invitation = '/invitation';
  static const confirmConnection = '/connect/level3/confirm-connection';
  static const confirmConnectionLevel1 = '/connect/level1/confirm-connection';
  static const enterPincode = '/security/enter-pincode';
  static const qrScreen = '/qr';
  static const scanQr = '/qr/scan';
  static const maintenance = '/system-status/maintenance';
  static const updateApp = '/system-status/update-app';
  static const invalidSecureKey = '/system-status/invalid-secure-key';
}

/// Skifter side uden animation
CustomTransitionPage<void> _buildPageWithTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}

bool _isInitialLoad = true;

final appRouter = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);
  final userExtra = ref.read(userExtraNotifierProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      print('\n=== Router Security Check ===');
      print(
          'Current auth state: ${isLoggedIn ? "LOGGED IN" : "NOT LOGGED IN"}');
      print('Attempting to access: ${state.location}');

      // Save for later
      // TERMS OF SERVICE CHECK - First priority
      // if (isLoggedIn) {
      //   print('🔍 🔍 🔍 🔍 🔍 Bruger er logget ind.');
      //   final isTermsConfirmed = userExtra.valueOrNull?.termsConfirmed ?? false;
      //   print(
      //       'Terms status: ${isTermsConfirmed ? "ACCEPTED" : "NOT ACCEPTED"}');

      //   if (!isTermsConfirmed && state.location != RoutePaths.termsOfService) {
      //     print('❌ Terms not accepted - forcing terms page');
      //     print('   - Current location: ${state.location}');
      //     print('   - Redirecting to: ${RoutePaths.termsOfService}');
      //     return RoutePaths.termsOfService;
      //   }
      // }

      // Handle auth callback errors
      final queryParams = state.queryParameters;
      if (queryParams.containsKey('error')) {
        print(
            '❌ Auth error detected: ${queryParams['error']} - ${queryParams['error_description']}');
        return RoutePaths.login;
      }

      // Handle successful auth callback
      if (state.location.contains('auth-callback') ||
          state.location.contains('login/auth-callback')) {
        print('🔐 Auth callback detected - ${state.location}');
        return RoutePaths.home;
      }

      // Vis kun splash screen ved første app load
      if (state.location == RoutePaths.splash && _isInitialLoad) {
        print('🚀 Initial app load - showing splash screen');
        _isInitialLoad = false;
        return null;
      }

      // Hvis brugeren lige er blevet logget ind via deep link,
      // skal de sendes til home
      if (state.location == RoutePaths.splash && isLoggedIn) {
        final deepLinkHandled =
            ref.read(authProvider.notifier).wasDeepLinkHandled;
        if (deepLinkHandled) {
          print('🔗 Auth via deep link detected - redirecting to home');
          return RoutePaths.home;
        }
      }

      // For alle andre requests
      if (state.location == RoutePaths.splash) {
        print('📱 Splash screen request - checking auth status');
        final destination = isLoggedIn ? RoutePaths.home : RoutePaths.login;
        print('🔄 Redirecting to: $destination');
        return destination;
      }

      // Beskyt auth-krævende routes
      if (isLoggedIn == false &&
          (state.location == RoutePaths.home ||
              state.location == RoutePaths.second ||
              state.location == RoutePaths.profile ||
              state.location == RoutePaths.contacts ||
              state.location == RoutePaths.demo ||
              state.location == RoutePaths.termsOfService ||
              state.location == RoutePaths.connect ||
              state.location == RoutePaths.securityKey)) {
        return RoutePaths.login;
      }

      print('✅ No redirect needed for ${state.location}');
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.checkEmail,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: CheckEmailScreen(
            email: state.extra as String? ?? '',
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.home,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.second,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: SecondPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.confirm,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const LoginLandingPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.profile,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ProfilePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.contacts,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ContactsScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.demo,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: DemoScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.authCallback,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const AuthCallbackScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.termsOfService,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: TermsOfServiceScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.personalInfo,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: OnboardingProfileScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.createPin,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: OnboardingPINScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.confirmPin,
        name: 'confirm-pin',
        pageBuilder: (context, state) {
          final pin = state.extra as String? ?? '';
          return _buildPageWithTransition(
            key: state.pageKey,
            child: OnboardingPINConfirmScreen(pinToConfirm: pin),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profileImage,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: OnboardingProfileImageScreen(),
        ),
      ),
      GoRoute(
        path: '/contact-verification/:contactId',
        pageBuilder: (context, state) {
          final contactId = state.pathParameters['contactId']!;
          return _buildPageWithTransition(
            key: state.pageKey,
            child: FutureBuilder(
              future: ContactVerificationScreen.create(contactId: contactId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const CircularProgressIndicator();
              },
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.connect,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ConnectScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingBegin,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: OnboardingBeginScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.onboardingComplete,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: OnboardingComplete(),
        ),
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
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ProfileEditScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.securityKey,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: SecurityKeyScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.connectLevel1,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ConnectLevel1Screen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.connectLevel3,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ConnectLevel3Screen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.qrCode,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: QRCodeScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.scanQrCode,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ScanQRCodeScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.confirmConnection,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ConfirmConnectionScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.confirmConnectionLevel1,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ConfirmConnectionLevel1Screen(),
        ),
      ),
      // Handle invitation links directly
      GoRoute(
        path: RoutePaths.invitation,
        redirect: (context, state) {
          final id = state.queryParameters['invite'];
          return id != null
              ? '${RoutePaths.confirmConnection}?invite=$id'
              : RoutePaths.home;
        },
      ),
      GoRoute(
        path: RoutePaths.enterPincode,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: EnterPincodePage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.qrScreen,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: QrScreen(qrCode: state.queryParameters['qr_code']),
        ),
      ),
      GoRoute(
        path: RoutePaths.scanQr,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: ScanQrCode(),
        ),
      ),
      GoRoute(
        path: RoutePaths.maintenance,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: MaintenanceScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.updateApp,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: UpdateAppScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.invalidSecureKey,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: InvalidSecureKeyScreen(),
        ),
      ),
    ],
  );
});
