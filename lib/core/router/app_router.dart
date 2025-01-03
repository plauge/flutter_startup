import '../../exports.dart';
import '../../providers/user_extra_provider.dart';

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
}

bool _isInitialLoad = true;

final appRouter = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      print('\n=== Router Security Check ===');
      print(
          'Current auth state: ${isLoggedIn ? "LOGGED IN" : "NOT LOGGED IN"}');
      print('Attempting to access: ${state.location}');

      // Check terms of service first if logged in
      if (isLoggedIn && state.location != RoutePaths.termsOfService) {
        final userExtra = ref.read(userExtraNotifierProvider);
        if (userExtra.valueOrNull?.termsConfirmed != true) {
          print('❌ Terms not accepted - redirecting to terms page');
          return RoutePaths.termsOfService;
        }
      }

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
              state.location == RoutePaths.termsOfService)) {
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
    ],
  );
});
