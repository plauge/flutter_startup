import '../exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    // Initialize Firebase Messaging
    _initializeFirebaseMessaging();
    // Listen to auth state changes from Supabase
    _supabaseService.client.auth.onAuthStateChange.listen(_handleAuthStateChange);
  }

  Future<void> _initializeAuthState() async {
    AppLogger.logSeparator('AuthNotifier _initializeAuthState');
    try {
      final currentUser = await _supabaseService.getCurrentUser();
      state = currentUser;
    } catch (e) {
      log('Error initializing auth state: $e');
      state = null;
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    AppLogger.logSeparator('AuthNotifier _initializeFirebaseMessaging');
    print('🚀 DEBUG: Firebase Messaging initialization started');

    try {
      print('🚀 DEBUG: Requesting Firebase permissions...');
      // Bed om notifikationstilladelse (kun nødvendigt på iOS)
      await FirebaseMessaging.instance.requestPermission();
      log('🔔 Firebase Messaging permissions requested');
      print('🚀 DEBUG: Permissions requested successfully');

      print('🚀 DEBUG: Getting FCM token...');

      // På iOS: Først få APNS token, så FCM token
      String? apnsToken;
      try {
        print('🚀 DEBUG: Getting APNS token first (iOS requirement)...');
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print('🚀 DEBUG: APNS Token: ${apnsToken != null ? 'RECEIVED' : 'NULL'}');
      } catch (apnsError) {
        print('🚀 DEBUG: APNS Token error: $apnsError');
      }

      // Vent lidt for at sikre APNS token er sat
      await Future.delayed(const Duration(seconds: 2));

      // Hent enhedens FCM-token med timeout
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('🚀 DEBUG: FCM Token request timed out after 15 seconds');
            return null;
          },
        );
      } catch (tokenError) {
        print('🚀 DEBUG: FCM Token error: $tokenError');
        token = null;
      }

      log('🔥 FCM Token: $token');
      print('🚀 DEBUG: FCM Token received: ${token != null ? 'YES' : 'NO'}');

      if (token == null) {
        print('🚀 DEBUG: Token is null - this is normal on iOS without proper APNS setup');
        print('🚀 DEBUG: For development, using Android device or emulator is recommended');

        // Development fallback - kun til test formål
        token = 'DEVELOPMENT_TOKEN_iOS_needs_paid_Apple_Developer_Account_for_real_push';
        print('🚀 DEBUG: Using development fallback token for testing');
      }

      // Extra synlig logging for kopiering
      AppLogger.logSeparator('FCM TOKEN FOR SUPABASE PUSH');
      print('===== KOPIER DETTE TOKEN TIL SUPABASE =====');
      print(token ?? 'NULL');
      print('============================================');
      AppLogger.logSeparator('');
    } catch (e, stackTrace) {
      log('❌ Error initializing Firebase Messaging: $e');
      print('🚀 DEBUG: Firebase Messaging error: $e');
      print('🚀 DEBUG: Stack trace: $stackTrace');
    }
  }

  void _handleAuthStateChange(AuthState authState) {
    AppLogger.logSeparator('AuthNotifier _handleAuthStateChange');
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
    AppLogger.logSeparator('AuthNotifier login');
    final result = await _supabaseService.login(email, password);
    if (result.$1 == null && result.$2 != null) {
      state = result.$2 as AppUser; // Gemmer User objektet
    }
    return result.$1; // Returnerer fejlbesked hvis der er en
  }

  // Funktion til at oprette en ny bruger
  Future<String?> createUser(String email, String password) async {
    AppLogger.logSeparator('AuthNotifier createUser');
    final errorMessage = await _supabaseService.createUser(email, password);
    // if (errorMessage == null) {
    //   state = true; // Opdater auth state til logged in
    // }
    return errorMessage;
  }

  // Replace both logout methods with a single signOut
  Future<void> signOut() async {
    AppLogger.logSeparator('AuthNotifier signOut');
    await _supabaseService.signOut();
    wasDeepLinkHandled = false; // Reset deep link handling
    state = null;
    log('🔒 User logged out');
  }

  Future<void> handleAuthRedirect(Uri uri) async {
    AppLogger.logSeparator('AuthNotifier handleAuthRedirect');
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
    AppLogger.logSeparator('AuthNotifier sendMagicLink');
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

  Future<String?> resetPassword(String email) async {
    AppLogger.logSeparator('AuthNotifier resetPassword');
    try {
      log('🔄 Sending password reset email to: $email');
      final errorMessage = await _supabaseService.resetPassword(email);
      if (errorMessage == null) {
        log('✅ Password reset email sent successfully');
      } else {
        log('❌ Password reset error: $errorMessage');
      }
      return errorMessage;
    } catch (e) {
      log('❌ Password reset error (Other): $e');
      return e.toString();
    }
  }
}
