import '../exports.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  Future<Map<String, dynamic>> loadProfile() async {
    try {
      final response =
          await _client.rpc('public_profile_load').select().single();

      if (response['status_code'] == 200) {
        return response['data']['profile'];
      }

      throw Exception(response['data']['message']);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }
}
