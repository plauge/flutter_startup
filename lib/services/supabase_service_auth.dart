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
        log('   - User ID: ${response.user!.id}');
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
        log('❌ Login failed: No user returned from signInWithPassword');
        return ('Login fejlede', null);
      }
    } on AuthException catch (e, stackTrace) {
      log('❌ Login failed - AuthException from Supabase:');
      log('   - message: ${e.message}');
      log('   - statusCode: ${e.statusCode}');
      log('   - Full toString: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
      return (e.toString(), null);
    } catch (e, stackTrace) {
      log('❌ Login failed - Unexpected error:');
      log('   - Type: ${e.runtimeType}');
      log('   - Message: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
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
        log('   - User ID: ${response.user!.id}');
        return null;
      } else {
        log('❌ User creation failed - no user returned from signUp');
        return 'Brugeroprettelse fejlede';
      }
    } on AuthException catch (e, stackTrace) {
      log('❌ User creation failed - AuthException from Supabase:');
      log('   - message: ${e.message}');
      log('   - statusCode: ${e.statusCode}');
      log('   - Full toString: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
      return e.toString();
    } catch (e, stackTrace) {
      log('❌ User creation failed - Unexpected error:');
      log('   - Type: ${e.runtimeType}');
      log('   - Message: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
      return e.toString();
    }
  }

  Future<String?> resetPassword(String email) async {
    AppLogger.logSeparator('SupabaseServiceAuth.resetPassword');
    try {
      log('🔄 Attempting to send reset password email to: $email');

      // Redirect directly to reset-password page instead of auth-callback
      // This allows Supabase to automatically authenticate the user
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'idtruster://reset-password',
      );

      log('✅ Reset password email sent successfully');
      return null;
    } on AuthException catch (e, stackTrace) {
      log('❌ Reset password failed - AuthException from Supabase:');
      log('   - message: ${e.message}');
      log('   - statusCode: ${e.statusCode}');
      log('   - Full toString: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
      return e.toString();
    } catch (e, stackTrace) {
      log('❌ Reset password failed - Unexpected error:');
      log('   - Type: ${e.runtimeType}');
      log('   - Message: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
      return e.toString();
    }
  }

  Future<String?> requestPasswordResetPin(String email) async {
    AppLogger.logSeparator('SupabaseServiceAuth.requestPasswordResetPin');
    try {
      log('🔄 Requesting password reset PIN for email: $email');

      final response = await client.rpc(
        'auth_request_password_reset_pin',
        params: {'input_email': email},
      );

      log('📥 Response from auth_request_password_reset_pin: $response');

      if (response == null) {
        log('❌ No response from auth_request_password_reset_pin');
        return 'No response from server';
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from auth_request_password_reset_pin');
          return 'Empty response from server';
        }

        final firstItem = response[0] as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int?;
        final data = firstItem['data'] as Map<String, dynamic>?;

        if (data == null) {
          log('❌ No data in response');
          return 'Invalid response format';
        }

        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String? ?? 'Unknown error';

        if (success && statusCode == 200) {
          log('✅ Password reset PIN requested successfully: $message');
          return null;
        } else {
          log('❌ Password reset PIN request failed: $message (status: $statusCode)');
          return message;
        }
      }

      // Handle single object response (fallback)
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        log('❌ No data in response');
        return 'Invalid response format';
      }

      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';

      if (success) {
        log('✅ Password reset PIN requested successfully: $message');
        return null;
      } else {
        log('❌ Password reset PIN request failed: $message');
        return message;
      }
    } catch (e, stackTrace) {
      log('❌ Error requesting password reset PIN: $e');
      log('Stack trace: $stackTrace');
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> resetPasswordWithPin(String email, String pin, String newPassword) async {
    AppLogger.logSeparator('SupabaseServiceAuth.resetPasswordWithPin');
    try {
      log('🔄 Resetting password with PIN for email: $email');

      final response = await client.rpc(
        'auth_reset_password_with_pin',
        params: {
          'input_email': email,
          'input_pin': pin,
          'input_new_password': newPassword,
        },
      );

      log('📥 Response from auth_reset_password_with_pin: $response');

      if (response == null) {
        log('❌ No response from auth_reset_password_with_pin');
        return {'success': false, 'message': 'No response from server'};
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from auth_reset_password_with_pin');
          return {'success': false, 'message': 'Empty response from server'};
        }

        final firstItem = response[0] as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int?;
        final data = firstItem['data'] as Map<String, dynamic>?;

        if (data == null) {
          log('❌ No data in response');
          return {'success': false, 'message': 'Invalid response format'};
        }

        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String? ?? 'Unknown error';
        final errorCode = data['error_code'] as String?;

        if (success && statusCode == 200) {
          log('✅ Password reset with PIN successful: $message');
          return {
            'success': true,
            'message': message,
          };
        } else {
          log('❌ Password reset with PIN failed: $message (status: $statusCode, error_code: $errorCode)');
          return {
            'success': false,
            'message': message,
            'error_code': errorCode,
          };
        }
      }

      // Handle single object response (fallback)
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        log('❌ No data in response');
        return {'success': false, 'message': 'Invalid response format'};
      }

      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';
      final errorCode = data['error_code'] as String?;

      if (success) {
        log('✅ Password reset with PIN successful: $message');
        return {
          'success': true,
          'message': message,
        };
      } else {
        log('❌ Password reset with PIN failed: $message');
        return {
          'success': false,
          'message': message,
          'error_code': errorCode,
        };
      }
    } catch (e, stackTrace) {
      log('❌ Error resetting password with PIN: $e');
      log('Stack trace: $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<String?> requestLoginPinCode(String email, String languageCode) async {
    AppLogger.logSeparator('SupabaseServiceAuth.requestLoginPinCode');
    try {
      log('🔄 Requesting login PIN code for email: $email, language: $languageCode');

      final response = await client.rpc(
        'auth_request_login_pin_code',
        params: {
          'input_email': email,
          'input_language_code': languageCode,
        },
      );

      log('📥 Response from auth_request_login_pin_code: $response');

      if (response == null) {
        log('❌ No response from auth_request_login_pin_code');
        return 'No response from server';
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from auth_request_login_pin_code');
          return 'Empty response from server';
        }

        final firstItem = response[0] as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int?;
        final data = firstItem['data'] as Map<String, dynamic>?;

        if (data == null) {
          log('❌ No data in response');
          return 'Invalid response format';
        }

        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String? ?? 'Unknown error';

        if (success && statusCode == 200) {
          log('✅ Login PIN code requested successfully: $message');
          return null;
        } else {
          log('❌ Login PIN code request failed: $message (status: $statusCode)');
          return message;
        }
      }

      // Handle single object response (fallback)
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        log('❌ No data in response');
        return 'Invalid response format';
      }

      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';

      if (success) {
        log('✅ Login PIN code requested successfully: $message');
        return null;
      } else {
        log('❌ Login PIN code request failed: $message');
        return message;
      }
    } catch (e, stackTrace) {
      log('❌ Error requesting login PIN code: $e');
      log('Stack trace: $stackTrace');
      return e.toString();
    }
  }

  Future<String?> requestLoginPinCodeV2(String email, String languageCode) async {
    AppLogger.logSeparator('SupabaseServiceAuth.requestLoginPinCodeV2');
    try {
      log('🔄 Requesting login PIN code V2 for email: $email, language: $languageCode');

      final response = await client.rpc(
        'auth_request_login_pin_code_v2',
        params: {
          'input_email': email,
          'input_language_code': languageCode,
        },
      );

      log('📥 Response from auth_request_login_pin_code_v2: $response');

      if (response == null) {
        log('❌ No response from auth_request_login_pin_code_v2');
        return 'No response from server';
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from auth_request_login_pin_code_v2');
          return 'Empty response from server';
        }

        final firstItem = response[0] as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int?;
        final data = firstItem['data'] as Map<String, dynamic>?;

        if (data == null) {
          log('❌ No data in response');
          return 'Invalid response format';
        }

        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String? ?? 'Unknown error';

        if (success && statusCode == 200) {
          log('✅ Login PIN code V2 requested successfully: $message');
          return null;
        } else {
          log('❌ Login PIN code V2 request failed: $message (status: $statusCode)');
          return message;
        }
      }

      // Handle single object response (fallback)
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        log('❌ No data in response');
        return 'Invalid response format';
      }

      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';

      if (success) {
        log('✅ Login PIN code V2 requested successfully: $message');
        return null;
      } else {
        log('❌ Login PIN code V2 request failed: $message');
        return message;
      }
    } catch (e, stackTrace) {
      log('❌ Error requesting login PIN code V2: $e');
      log('Stack trace: $stackTrace');
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> resetPasswordOrCreateUser(String email, String pin, String newPassword) async {
    AppLogger.logSeparator('SupabaseServiceAuth.resetPasswordOrCreateUser');
    try {
      log('🔄 Resetting password or creating user with PIN for email: $email');

      // Log which database we're connecting to
      final supabaseUrl = client.supabaseUrl;
      log('🔗 Supabase URL being used: $supabaseUrl');
      if (supabaseUrl.contains('iehraurjkiqqjmemrfdl')) {
        log('✅ VERIFIED: Using TEST database');
      } else if (supabaseUrl.contains('nzggkotdqyyefjsynhlm')) {
        log('⚠️ WARNING: Using PRODUCTION database!');
      } else {
        log('❓ Unknown database URL');
      }

      final response = await client.rpc(
        'auth_reset_password_or_create_user',
        params: {
          'input_email': email,
          'input_pin': pin,
          'input_new_password': newPassword,
        },
      );

      log('📥 Response from auth_reset_password_or_create_user: $response');

      if (response == null) {
        log('❌ No response from auth_reset_password_or_create_user');
        return {'success': false, 'message': 'No response from server'};
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from auth_reset_password_or_create_user');
          return {'success': false, 'message': 'Empty response from server'};
        }

        final firstItem = response[0] as Map<String, dynamic>;
        final statusCode = firstItem['status_code'] as int?;
        final data = firstItem['data'] as Map<String, dynamic>?;

        if (data == null) {
          log('❌ No data in response');
          return {'success': false, 'message': 'Invalid response format'};
        }

        final success = data['success'] as bool? ?? false;
        final message = data['message'] as String? ?? 'Unknown error';
        final errorCode = data['error_code'] as String?;
        final payload = data['payload'] as Map<String, dynamic>?;
        log('📦 Payload received: $payload');
        final action = payload?['action'] as String?;
        log('📋 Action extracted from payload: $action');

        if (success && statusCode == 200) {
          log('✅ Password reset or user creation with PIN successful: $message');
          log('📋 Action from payload: $action');
          return {
            'success': true,
            'message': message,
            'action': action,
          };
        } else {
          log('❌ Password reset or user creation with PIN failed: $message (status: $statusCode, error_code: $errorCode)');
          return {
            'success': false,
            'message': message,
            'error_code': errorCode,
          };
        }
      }

      // Handle single object response (fallback)
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        log('❌ No data in response');
        return {'success': false, 'message': 'Invalid response format'};
      }

      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';
      final errorCode = data['error_code'] as String?;
      final payload = data['payload'] as Map<String, dynamic>?;
      final action = payload?['action'] as String?;

      if (success) {
        log('✅ Password reset or user creation with PIN successful: $message');
        log('📋 Action from payload: $action');
        return {
          'success': true,
          'message': message,
          'action': action,
        };
      } else {
        log('❌ Password reset or user creation with PIN failed: $message');
        return {
          'success': false,
          'message': message,
          'error_code': errorCode,
        };
      }
    } catch (e, stackTrace) {
      log('❌ Error resetting password or creating user with PIN: $e');
      log('Stack trace: $stackTrace');
      return {'success': false, 'message': e.toString()};
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
    } on AuthException catch (e, stackTrace) {
      log('❌ Password update failed - AuthException from Supabase:');
      log('   - message: ${e.message}');
      log('   - statusCode: ${e.statusCode}');
      log('   - Full toString: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
      return e.toString();
    } catch (e, stackTrace) {
      log('❌ Password update failed - Unexpected error:');
      log('   - Type: ${e.runtimeType}');
      log('   - Message: $e');
      log('   - Stack trace (first 5 lines): ${stackTrace.toString().split("\n").take(5).join("\n")}');
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
