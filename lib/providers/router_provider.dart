// Dette er en router provider fil der håndterer navigation i appen
// Den bruger GoRouter til at definere routes og redirect logik

import '../exports.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // VIGTIGT: Brug watch i stedet for read for at reagere på ændringer
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      print('\n=== Router Security Check ===');
      print(
          'Current auth state: ${isLoggedIn ? "LOGGED IN" : "NOT LOGGED IN"}');
      print('Attempting to access: ${state.location}');

      // Tillad adgang til login_check_email uden at være logget ind
      if (state.location == '/login_check_email') {
        print('✅ Allowing access to email verification page');
        return null;
      }

      // VIGTIG ÆNDRING: Tjek auth status først
      if (!isLoggedIn) {
        print('❌ Not logged in - forcing redirect to login');
        return '/login';
      }

      // Hvis logget ind og prøver at gå til login
      if (isLoggedIn && state.location == '/login') {
        print('ℹ️ Already logged in - redirecting to home');
        return '/home';
      }

      print('✅ Access granted to ${state.location}');
      return null;
    },
    routes: [
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
