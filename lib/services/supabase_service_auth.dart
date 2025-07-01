part of 'supabase_service.dart';

extension SupabaseServiceAuth on SupabaseService {
  static final log = scopedLogger(LogCategory.service);

  Future<AppUser?> getCurrentUser() async {
    AppLogger.logSeparator('SupabaseServiceAuth.getCurrentUser');
    try {
      log('🔍 Getting current user...');
      final user = client.auth.currentUser;
      if (user != null) {
        log('✅ Current user found: ${user.email}');
        return AppUser(
          id: user.id,
          email: user.email ?? '',
          createdAt: DateTime.parse(user.createdAt),
          lastLoginAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : DateTime.now(),
        );
      }
      log('ℹ️ No current user found');
      return null;
    } catch (e) {
      log('❌ Error getting current user: $e');
      return null;
    }
  }

  Future<(String?, AppUser?)> login(String email, String password) async {
    AppLogger.logSeparator('SupabaseServiceAuth.login');
    try {
      log('🔄 Attempting login for email: $email');
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        log('✅ Login successful for: ${response.user!.email}');
        return (
          null,
          AppUser(
            id: response.user!.id,
            email: response.user!.email ?? '',
            createdAt: DateTime.parse(response.user!.createdAt),
            lastLoginAt: response.user!.lastSignInAt != null ? DateTime.parse(response.user!.lastSignInAt!) : DateTime.now(),
          )
        );
      } else {
        log('❌ Login failed: No user returned');
        return ('Login fejlede', null);
      }
    } catch (e) {
      log('❌ Login error: $e');
      return (e.toString(), null);
    }
  }

  Future<String?> createUser(String email, String password) async {
    AppLogger.logSeparator('SupabaseServiceAuth.createUser');
    try {
      log('🔄 Attempting to create user with email: $email');

      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'idtruster://magic-link',
      );

      if (response.user != null) {
        log('✅ User created successfully: ${response.user!.email}');
        return null;
      } else {
        log('❌ User creation failed - no user returned');
        return 'Brugeroprettelse fejlede';
      }
    } catch (e) {
      log('❌ User creation error: $e');
      return e.toString();
    }
  }

  Future<String?> resetPassword(String email) async {
    AppLogger.logSeparator('SupabaseServiceAuth.resetPassword');
    try {
      log('Attempting to send reset password email to: $email');

      await client.auth.resetPasswordForEmail(email);

      log('Reset password email sent successfully');
      return null;
    } catch (e) {
      log('Reset password error: $e');
      return e.toString();
    }
  }

  Future<void> signOut() async {
    AppLogger.logSeparator('SupabaseServiceAuth.signOut');
    try {
      log('🔄 Attempting to sign out user');
      await client.auth.signOut();
      log('✅ User signed out successfully');
    } catch (e) {
      log('❌ Sign out error: $e');
      throw e;
    }
  }

  Future<void> sendMagicLink(String email) async {
    AppLogger.logSeparator('SupabaseServiceAuth.sendMagicLink');
    try {
      log('🔄 Sending magic link to: $email');
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'idtruster://magic-link',
        shouldCreateUser: true,
      );
      log('✅ Magic link sent successfully');
    } catch (e) {
      log('❌ Magic link error: $e');
      rethrow;
    }
  }
}
