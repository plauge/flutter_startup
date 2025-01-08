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
}

bool _isInitialLoad = true;

final appRouter = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);
  final userExtra = ref.watch(userExtraNotifierProvider);

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
              state.location == RoutePaths.connect)) {
        return RoutePaths.login;
      }

      print('✅ No redirect needed for ${state.location}');
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/check-email',
        builder: (context, state) => const CheckEmailScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: RoutePaths.second,
        builder: (context, state) => SecondPage(),
      ),
      GoRoute(
        path: RoutePaths.confirm,
        builder: (context, state) => const LoginLandingPage(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.contacts,
        builder: (context, state) => ContactsScreen(),
      ),
      GoRoute(
        path: RoutePaths.demo,
        builder: (context, state) => DemoScreen(),
      ),
      GoRoute(
        path: RoutePaths.authCallback,
        builder: (context, state) => const AuthCallbackScreen(),
      ),
      GoRoute(
        path: RoutePaths.termsOfService,
        builder: (context, state) => TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/onboarding/personal-info',
        builder: (context, state) => PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/contact-verification/:contactId',
        builder: (context, state) {
          final contactId = state.pathParameters['contactId']!;
          return FutureBuilder(
            future: ContactVerificationScreen.create(contactId: contactId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              }
              return const CircularProgressIndicator();
            },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.connect,
        builder: (context, state) => ConnectScreen(),
      ),
    ],
  );
});
