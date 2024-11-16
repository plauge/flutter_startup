import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart' as app_user;

class SupabaseService {
  final client = supabase.Supabase.instance.client;

  Future<app_user.User?> getCurrentUser() async {
    final supabaseUser = client.auth.currentUser;
    if (supabaseUser == null) return null;

    return app_user.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      createdAt: DateTime.parse(supabaseUser.createdAt),
      lastLoginAt: supabaseUser.lastSignInAt != null
          ? DateTime.parse(supabaseUser.lastSignInAt!)
          : DateTime.now(),
    );
  }

  Future<(String?, app_user.User?)> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('Login successful');
        return (
          null,
          app_user.User(
            id: response.user!.id,
            email: response.user!.email!,
            createdAt: DateTime.parse(response.user!.createdAt),
            lastLoginAt: response.user!.lastSignInAt != null
                ? DateTime.parse(response.user!.lastSignInAt!)
                : DateTime.now(),
          )
        );
      } else {
        print('Login failed - no user returned');
        return ('Login fejlede', null);
      }
    } catch (e) {
      print('Login error: $e');
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
