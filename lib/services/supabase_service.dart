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

      if (response.user != null) {
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
}
