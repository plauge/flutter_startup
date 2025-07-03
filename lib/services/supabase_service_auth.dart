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

      // Redirect directly to reset-password page instead of auth-callback
      // This allows Supabase to automatically authenticate the user
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'idtruster://reset-password',
      );

      log('Reset password email sent successfully');
      return null;
    } catch (e) {
      log('Reset password error: $e');
      return e.toString();
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    AppLogger.logSeparator('SupabaseServiceAuth.updatePassword');
    try {
      log('🔄 Attempting to update user password');

      // The user should already be authenticated from the reset password link
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        log('❌ No authenticated user found');
        return 'User not authenticated. Please click the reset password link again.';
      }

      log('✅ User authenticated: ${currentUser.email}');

      // Update the password directly since user is already authenticated
      final updateResponse = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (updateResponse.user != null) {
        log('✅ Password updated successfully for user: ${updateResponse.user!.email}');
        return null;
      } else {
        log('❌ Password update failed - no user returned');
        return 'Password update failed';
      }
    } catch (e) {
      log('❌ Password update error: $e');
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

  Future<String?> handleResetPasswordFromUrl(Uri uri, String newPassword) async {
    AppLogger.logSeparator('SupabaseServiceAuth.handleResetPasswordFromUrl');
    log('🚀 METHOD ENTRY - handleResetPasswordFromUrl called');
    log('🔄 STARTING password reset process with URI');
    log('📋 INPUT PARAMETERS:');
    log('   - URI: $uri');
    log('   - New password length: ${newPassword.length}');
    log('   - Current user before reset: ${client.auth.currentUser?.email ?? "None"}');

    try {
      // Input validation
      if (newPassword.isEmpty) {
        log('❌ VALIDATION FAILED: Empty password provided');
        return 'Password cannot be empty';
      }

      if (newPassword.length < 6) {
        log('❌ VALIDATION FAILED: Password too short (${newPassword.length} chars)');
        return 'Password must be at least 6 characters';
      }

      log('✅ INPUT VALIDATION passed');
      log('🔐 ATTEMPTING to hydrate session from URL...');

      // 1) Hydrate session from #access_token in the link
      await client.auth.getSessionFromUrl(uri, storeSession: true);

      log('✅ SESSION HYDRATED successfully');
      log('   - Current auth user: ${client.auth.currentUser?.email ?? "None"}');

      // 2) Update the password
      log('🔄 ATTEMPTING to update user password...');
      await client.auth.updateUser(UserAttributes(password: newPassword));

      log('✅ PASSWORD UPDATE SUCCESS');
      log('🎉 RESET PASSWORD PROCESS COMPLETED SUCCESSFULLY');
      return null;
    } catch (e, stackTrace) {
      log('❌ EXCEPTION OCCURRED during password reset process');
      log('   - Exception type: ${e.runtimeType}');
      log('   - Exception message: $e');
      log('   - Full exception: ${e.toString()}');
      log('   - Stack trace preview: ${stackTrace.toString().split('\n').take(5).join('\n')}');

      // Specific error analysis
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('expired')) {
        log('💡 ERROR ANALYSIS: Link appears to be expired');
        return 'Reset link has expired - please request a new password reset';
      } else if (errorStr.contains('invalid')) {
        log('💡 ERROR ANALYSIS: Link appears to be invalid');
        return 'Invalid reset link - please request a new password reset';
      } else if (errorStr.contains('network') || errorStr.contains('connection')) {
        log('💡 ERROR ANALYSIS: Network/connection issue');
        return 'Network error - please check your connection and try again';
      }

      log('🔄 RETURNING raw error to user for debugging');
      return e.toString();
    }
  }
}
