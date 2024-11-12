import '../exports.dart';

// final authProvider = StateProvider<bool>((ref) {
//   print('⭐ Creating authProvider with initial value: false');
//   return true;
// });

// // Tilføj denne nye provider for at tracke ændringer
// final authListenerProvider = Provider((ref) {
//   ref.listen(authProvider, (previous, next) {
//     print('🔐 Auth state changed from $previous to $next');
//     print('Stack trace:');
//     print(StackTrace.current);
//   });
//   return null;
// });

// StateNotifierProvider til at administrere auth-state
final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(SupabaseService()),
);

// Provider til at overvåge ændringer i auth-state
final authListenerProvider = Provider<void>((ref) {
  ref.listen<bool>(authProvider, (previous, next) {
    print('🔐 Auth state changed from $previous to $next');
    print('Stack trace:');
    print(StackTrace.current);
  });
});

// AuthNotifier-klasse til at håndtere login- og logout-handlinger
class AuthNotifier extends StateNotifier<bool> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(false);

  // Funktion til at logge brugeren ind
  Future<String?> login(String email, String password) async {
    final errorMessage = await _supabaseService.login(email, password);
    if (errorMessage == null) {
      state = true; // Opdater auth state til logged in
    }
    return errorMessage;
  }

  // Funktion til at logge brugeren ud
  void logout() {
    state = false;
    print('🔒 User logged out');
  }
}
