import '../exports.dart';

class ProfileService {
  final SupabaseClient _client;
  static final log = scopedLogger(LogCategory.service);

  ProfileService(this._client);

  Future<Map<String, dynamic>> loadProfile() async {
    try {
      final response = await _client.rpc('public_profile_load').select().single();

      if (response['status_code'] == 200) {
        return response['data']['profile'];
      }

      throw Exception(response['data']['message']);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String company,
    required String profileImage,
  }) async {
    try {
      await _client.rpc(
        'public_profile_update',
        params: {
          'input_first_name': firstName,
          'input_last_name': lastName,
          'input_company': company,
          'input_profile_image': profileImage,
        },
      );

      // After successful update, reload the profile
      await Future.delayed(const Duration(milliseconds: 500));
      return loadProfile();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
