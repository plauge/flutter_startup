import '../exports.dart';
//import '../models/app_user.dart';

// StateNotifierProvider til at administrere auth-state
final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>((ref) {
  return AuthNotifier(SupabaseService());
});

/// Provider der kun eksponerer login status uden at give adgang til User objektet
final authStateProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user != null;
});

// Provider til at overvåge ændringer i auth-state
final authListenerProvider = Provider<void>((ref) {
  ref.listen<AppUser?>(authProvider, (previous, next) {
    print('🔐 Auth state changed: ${next?.email ?? 'logged out'}');
    print(StackTrace.current);
  });
});

// AuthNotifier-klasse til at håndtere login- og logout-handlinger
class AuthNotifier extends StateNotifier<AppUser?> {
  static final log = scopedLogger(LogCategory.provider);
  final SupabaseService _supabaseService;
  bool wasDeepLinkHandled = false;

  AuthNotifier(this._supabaseService) : super(null) {
    // Initialize auth state when provider is created
    _initializeAuthState();
    // Listen to auth state changes from Supabase
    _supabaseService.client.auth.onAuthStateChange.listen(_handleAuthStateChange);
  }

  Future<void> _initializeAuthState() async {
    try {
      final currentUser = await _supabaseService.getCurrentUser();
      state = currentUser;
    } catch (e) {
      log('Error initializing auth state: $e');
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
      state = AppUser(
        id: user.id,
        email: user.email ?? '',
        createdAt: DateTime.parse(user.createdAt),
        lastLoginAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : DateTime.now(),
      );
    }

    if (authState.event == AuthChangeEvent.signedIn) {
      wasDeepLinkHandled = true;
    }
  }

  // Funktion til at logge brugeren ind
  Future<String?> login(String email, String password) async {
    final result = await _supabaseService.login(email, password);
    if (result.$1 == null && result.$2 != null) {
      state = result.$2 as AppUser; // Gemmer User objektet
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
    wasDeepLinkHandled = false; // Reset deep link handling
    state = null;
    log('🔒 User logged out');
  }

  Future<void> handleAuthRedirect(Uri uri) async {
    try {
      log('🔍 Auth Provider - Starting redirect handling');
      log('🔍 Full URI: $uri');
      log('🔍 Path: ${uri.path}');
      log('🔍 Query parameters: ${uri.queryParameters}');

      final code = uri.queryParameters['code'];
      if (code == null) {
        log('❌ Auth Provider - No code found in query parameters.');
        return;
      }

      log('✅ Auth Provider - Found code: $code');
      log('🔄 Auth Provider - Getting session from URL...');

      final response = await _supabaseService.client.auth.getSessionFromUrl(uri);
      log('📦 Auth Provider - Session response: ${response.session?.user.email ?? 'No session'}');

      if (response.session != null) {
        final user = response.session!.user;
        log('👤 Auth Provider - User details:');
        log('   - ID: ${user.id}');
        log('   - Email: ${user.email}');
        log('   - Created at: ${user.createdAt}');

        state = AppUser(
          id: user.id,
          email: user.email ?? '',
          createdAt: DateTime.parse(user.createdAt),
          lastLoginAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : DateTime.now(),
        );
        wasDeepLinkHandled = true;
        log('✅ Auth Provider - User state updated successfully');
      } else {
        log('❌ Auth Provider - No session returned from getSessionFromUrl');
      }
    } catch (e, stackTrace) {
      log('❌ Auth Provider - Error getting session:');
      log('Error: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> sendMagicLink(String email) async {
    try {
      log('🔄 Sending magic link to: $email');
      await _supabaseService.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'idtruster://magic-link',
        shouldCreateUser: true,
      );
      log('✅ Magic link sent successfully');
      return null;
    } on AuthException catch (error) {
      log('❌ Magic link error (AuthException): ${error.message}');
      return error.message;
    } catch (e) {
      log('❌ Magic link error (Other): $e');
      return e.toString();
    }
  }
}
