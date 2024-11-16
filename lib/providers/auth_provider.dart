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

  AuthNotifier(this._supabaseService) : super(null) {
    // Initialize auth state when provider is created
    _initializeAuthState();
    // Listen to auth state changes from Supabase
    _supabaseService.client.auth.onAuthStateChange
        .listen(_handleAuthStateChange);
  }

  Future<void> _initializeAuthState() async {
    try {
      final currentUser = await _supabaseService.getCurrentUser();
      state = currentUser;
    } catch (e) {
      print('Error initializing auth state: $e');
      state = null;
    }
  }

  void _handleAuthStateChange(AuthState authState) {
    if (authState.event == AuthChangeEvent.signedOut) {
      state = null;
      return;
    }

    final user = authState.session?.user;
    if (user != null) {
      state = app_user.User(
        id: user.id,
        email: user.email ?? '',
        createdAt: DateTime.parse(user.createdAt),
        lastLoginAt: user.lastSignInAt != null
            ? DateTime.parse(user.lastSignInAt!)
            : DateTime.now(),
      );
    }
  }

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

  // Replace both logout methods with a single signOut
  Future<void> signOut() async {
    await _supabaseService.signOut();
    state = null;
    print('🔒 User logged out');
  }
}
