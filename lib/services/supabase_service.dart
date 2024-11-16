import '../exports.dart';

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
}
