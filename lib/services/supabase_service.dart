import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<String?> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        print('Login successful');
        return null;
      } else {
        print('Login failed - no user returned');
        return 'Login fejlede';
      }
    } catch (e) {
      print('Login error: $e');
      return e.toString();
    }
  }

  Future<String?> createUser(String email, String password) async {
    try {
      print('Attempting to create user with email: $email');

      final response = await supabase.auth.signUp(
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

      await supabase.auth.resetPasswordForEmail(
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
}
