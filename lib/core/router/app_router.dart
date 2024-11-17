import '../../exports.dart';

class RoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const checkEmail = '/login_check_email';
  static const home = '/home';
  static const second = '/second';
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

      // Vis kun splash screen ved første app load
      if (state.location == RoutePaths.splash && _isInitialLoad) {
        _isInitialLoad = false;
        return null;
      }

      // For alle andre '/' requests, redirect baseret på auth status
      if (state.location == RoutePaths.splash) {
        return isLoggedIn ? RoutePaths.home : RoutePaths.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.checkEmail,
        builder: (context, state) => const CheckEmailPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.second,
        builder: (context, state) => const SecondPage(),
      ),
    ],
  );
});
