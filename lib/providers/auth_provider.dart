import '../exports.dart';
import '../models/user.dart' as app_user;

// StateNotifierProvider til at administrere auth-state
final authProvider = StateNotifierProvider<AuthNotifier, app_user.User?>((ref) {
  return AuthNotifier(SupabaseService());
});

// Provider til at overvåge ændringer i auth-state
final authListenerProvider = Provider<void>((ref) {
  ref.listen<app_user.User?>(authProvider, (previous, next) {
    print('🔐 Auth state changed: ${next?.email ?? 'logged out'}');
    print(StackTrace.current);
  });
});

// AuthNotifier-klasse til at håndtere login- og logout-handlinger
class AuthNotifier extends StateNotifier<app_user.User?> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(null);

  // Funktion til at logge brugeren ind
  Future<String?> login(String email, String password) async {
    final result = await _supabaseService.login(email, password);
    if (result.$1 == null && result.$2 != null) {
      state = result.$2 as app_user.User; // Gemmer User objektet
    }
    return result.$1; // Returnerer fejlbesked hvis der er en
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
    state = null;
    print('🔒 User logged out');
  }

  void signOut() {
    state = null;
    _supabaseService.signOut();
    print('🔒 User logged out');
  }
}
