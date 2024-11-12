import '../exports.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Login-funktion
  Future<String?> login(String email, String password) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      return null; // Returner null, hvis login er succesfuldt
    } on AuthException catch (e) {
      return e.message; // Returner fejlbesked, hvis login fejler
    }
  }

  // Eksempel på tidligere funktion
  Future<User?> getUserById(String id) async {
    try {
      final response =
          await _client.from('users').select().eq('id', id).single();
      final data = response.data as Map<String, dynamic>;
      return User(
        id: data['id'] as String,
        email: data['email'] as String,
        aud: 'authenticated',
        appMetadata: {},
        userMetadata: {},
        createdAt: data['created_at'] as String,
        updatedAt: data['created_at'] as String,
        phone: '',
        confirmedAt: data['created_at'] as String,
        emailConfirmedAt: data['created_at'] as String,
        lastSignInAt: data['last_login_at'] as String,
        role: '',
        factors: [],
      );
    } catch (e) {
      return null;
    }
  }
}
