import '../exports.dart';
import '../models/user_extra.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  Future<AppUser?> getCurrentUser() async {
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        return AppUser(
          id: user.id,
          email: user.email ?? '',
          createdAt: DateTime.parse(user.createdAt),
          lastLoginAt: user.lastSignInAt != null
              ? DateTime.parse(user.lastSignInAt!)
              : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<(String?, AppUser?)> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return (
          null,
          AppUser(
            id: response.user!.id,
            email: response.user!.email ?? '',
            createdAt: DateTime.parse(response.user!.createdAt),
            lastLoginAt: response.user!.lastSignInAt != null
                ? DateTime.parse(response.user!.lastSignInAt!)
                : DateTime.now(),
          )
        );
      } else {
        return ('Login fejlede', null);
      }
    } catch (e) {
      return (e.toString(), null);
    }
  }

  Future<String?> createUser(String email, String password) async {
    try {
      print('Attempting to create user with email: $email');

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('User created successfully');
        return null;
      } else {
        print('User creation failed - no user returned');
        return 'Brugeroprettelse fejlede';
      }
    } catch (e) {
      print('User creation error: $e');
      return e.toString();
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      print('Attempting to send reset password email to: $email');

      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://reset-callback/',
      );

      print('Reset password email sent successfully');
      return null;
    } catch (e) {
      print('Reset password error: $e');
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      print('Attempting to sign out user');
      await client.auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
      throw e;
    }
  }

  Future<void> sendMagicLink(String email) async {
    try {
      print('Sending magic link to: $email');
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'vegr://login/auth-callback',
        shouldCreateUser: true,
      );
      print('Magic link sent successfully');
    } catch (e) {
      print('Magic link error: $e');
      rethrow;
    }
  }

  Future<UserExtra?> getUserExtra() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final response = await client
          .from('user_extra')
          .select()
          .eq('user_id', user.id)
          .single();

      return UserExtra.fromDatabaseJson(response);
    } catch (e) {
      print('Error getting user extra: $e');
      return null;
    }
  }

  Future<void> updateUserExtra(UserExtra userExtra) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await client.from('user_extra').upsert({
        'user_id': user.id,
        'created_at': userExtra.createdAt.toIso8601String(),
        'status': userExtra.status,
        'latest_load': userExtra.latestLoad?.toIso8601String(),
        'hash_pincode': userExtra.hashPincode,
        'email_confirmed': userExtra.emailConfirmed,
        'terms_confirmed': userExtra.termsConfirmed,
        'user_extra_id': userExtra.userExtraId,
        'salt_pincode': userExtra.saltPincode,
        'onboarding': userExtra.onboarding,
        'encrypted_masterkey_check_value':
            userExtra.encryptedMasterkeyCheckValue,
        'email': userExtra.email,
        'user_type': userExtra.userType,
        'securekey_is_saved': userExtra.securekeyIsSaved,
      }).eq('user_extra_id', userExtra.userExtraId);
    } catch (e) {
      print('Error updating user extra: $e');
      throw Exception('Failed to update user extra: $e');
    }
  }
}
