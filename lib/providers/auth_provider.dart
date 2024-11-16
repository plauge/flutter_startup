import '../exports.dart';

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

  // Funktion til at oprette en ny bruger
  Future<String?> createUser(String email, String password) async {
    final errorMessage = await _supabaseService.createUser(email, password);
    // if (errorMessage == null) {
    //   state = true; // Opdater auth state til logged in
    // }
    return errorMessage;
  }

  // Funktion til at logge brugeren ud
  void logout() {
    state = false;
    print('🔒 User logged out');
  }

  void signOut() {
    state = false;
    print('🔒 User logged out');
    _supabaseService.signOut();
  }
}
