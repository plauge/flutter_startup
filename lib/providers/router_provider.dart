// Dette er en router provider fil der håndterer navigation i appen
// Den bruger GoRouter til at definere routes og redirect logik

import '../exports.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Holder styr på om brugeren er logget ind via auth provider
  final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    // App starter på login siden
    initialLocation: '/login',

    // Redirect logik der beskytter routes
    redirect: (context, state) {
      // Liste over routes der ikke kræver login
      const openRoutes = ['/login'];

      // Hvis bruger ikke er logget ind og prøver at tilgå beskyttet route
      // -> Send til login
      if (!isLoggedIn && !openRoutes.contains(state.location)) {
        return '/login';
      }

      // Hvis bruger er logget ind og er på login siden
      // -> Send til home
      if (isLoggedIn && state.location == '/login') {
        return '/home';
      }

      // Ingen redirect nødvendig
      return null;
    },

    // Definition af app routes/sider
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      //GoRoute(path: '/second', builder: (context, state) => SecondPage()),

      // Tilføj dine beskyttede sider her
      //GoRoute(path: '/protected', builder: (context, state) => ProtectedPage()),
    ],
  );
});
