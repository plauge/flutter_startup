// Dette er en router provider fil der håndterer navigation i appen
// Den bruger GoRouter til at definere routes og redirect logik

import '../exports.dart';
import '../screens/splash_screen.dart';

// Flyt isInitialLoad udenfor provider scope så den bevarer sin værdi
bool isInitialLoad = true;

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      print('\n=== Router Security Check ===');
      print(
          'Current auth state: ${isLoggedIn ? "LOGGED IN" : "NOT LOGGED IN"}');
      print('Attempting to access: ${state.location}');

      // Vis kun splash screen ved første app load
      if (state.location == '/' && isInitialLoad) {
        isInitialLoad = false;
        return null;
      }

      // For alle andre '/' requests, redirect baseret på auth status
      if (state.location == '/') {
        return isLoggedIn ? '/home' : '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/login_check_email',
        builder: (context, state) => const CheckEmailPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/second',
        builder: (context, state) => const SecondPage(),
      ),
    ],
  );
});
