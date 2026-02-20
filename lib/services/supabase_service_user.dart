part of 'supabase_service.dart';

class UserExtraNotFoundException implements Exception {
  final String message;
  UserExtraNotFoundException(this.message);
}

extension SupabaseServiceUser on SupabaseService {
  static final log = scopedLogger(LogCategory.service);

  Future<UserExtra?> getUserExtra() async {
    try {
      final user = client.auth.currentUser;
      log('=== getUserExtra Start ===');
      log('Current user: ${user?.email}');
      log('User ID: ${user?.id}');

      if (user == null) {
        log('❌ No authenticated user found');
        return null;
      }

      log('\n🔄 Calling user_extra_read database function...');

      final response = await client.rpc('user_extra_read').execute();

      log('\n📥 Response Details:');
      log('Raw response data: ${response.data}');

      final List<dynamic> results = response.data as List<dynamic>;
      if (results.isEmpty) {
        log('❌ No results returned from RPC');
        return null;
      }

      final Map<String, dynamic> result = results[0] as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>;

      if (!data['success']) {
        log('❌ Operation not successful');
        log('Error message: ${data['message']}');
        return null;
      }

      final payload = data['payload'];
      if (payload == null) {
        log('❌ No user extra data found');
        throw UserExtraNotFoundException('No user extra data found - critical error');
      }

      final userExtraJson = payload['user_extra'] as Map<String, dynamic>;
      log('\n📋 User Extra data:');
      log('Fields: ${userExtraJson.keys.join(', ')}');

      return UserExtra.fromJson(userExtraJson);
    } catch (e, stackTrace) {
      log('\n❌ Error in getUserExtra:');
      log('Error type: ${e.runtimeType}');
      log('Error message: $e');
      log('Stack trace:\n$stackTrace');

      if (e is UserExtraNotFoundException) rethrow;
      return null;
    }
  }

  // TODO: Can be deleted after 2026-03-01 if no errors are reported.
  // Commented out because it calls user_extra table directly without RPC.
  // All user_extra updates now go through dedicated RPC functions.
  // Future<void> updateUserExtra(UserExtra userExtra) async {
  //   try {
  //     final user = client.auth.currentUser;
  //     if (user == null) throw Exception('User not authenticated');
  //
  //     await client.from('user_extra').upsert({
  //       'user_id': user.id,
  //       'created_at': userExtra.createdAt.toIso8601String(),
  //       'status': userExtra.status,
  //       'latest_load': userExtra.latestLoad?.toIso8601String(),
  //       'hash_pincode': userExtra.hashPincode,
  //       'email_confirmed': userExtra.emailConfirmed,
  //       'terms_confirmed': userExtra.termsConfirmed,
  //       'user_extra_id': userExtra.userExtraId,
  //       'salt_pincode': userExtra.saltPincode,
  //       'onboarding': userExtra.onboarding,
  //       'encrypted_masterkey_check_value': userExtra.encryptedMasterkeyCheckValue,
  //       'email': userExtra.email,
  //       'user_type': userExtra.userType,
  //       'securekey_is_saved': userExtra.securekeyIsSaved,
  //     }).eq('user_extra_id', userExtra.userExtraId);
  //   } catch (e) {
  //     log('Error updating user extra: $e');
  //     throw Exception('Failed to update user extra: $e');
  //   }
  // }

  Future<bool> updateTermsConfirmed() async {
    try {
      final response = await client.rpc('user_extra_update_terms_confirmed').select().single();

      if (response is Map) {
        final success = response['data']?['success'] ?? false;
        if (success) {
          log('✅ Terms of service updated successfully');
        } else {
          log('❌ Failed to update terms of service');
        }
        return success;
      }
      return false;
    } catch (e) {
      log('Error updating terms confirmed: $e');
      return false;
    }
  }

  Future<dynamic> completeOnboarding({
    required String firstName,
    required String lastName,
    required String company,
    required String encryptedFirstName,
    required String encryptedLastName,
    required String encryptedCompany,
  }) async {
    final response = await client.rpc('public_profiles_complete_onboarding', params: {
      'input_first_name': firstName,
      'input_last_name': lastName,
      'input_company': company,
      'input_encrypted_first_name': encryptedFirstName,
      'input_encrypted_last_name': encryptedLastName,
      'input_encrypted_company': encryptedCompany,
    }).execute();

    if (response.status != 200) {
      throw Exception('Error completing onboarding.');
    }

    return response.data;
  }

  Future<bool> setOnboardingPincode(String pincode) async {
    try {
      final response = await client.rpc('security_onboarding_set_pincode', params: {
        'input_pincode': pincode,
      }).execute();

      log('\n📥 SetOnboardingPincode Response:');
      log('Raw response: ${response.data}');

      // Response kommer som en liste, så vi tager første element
      final firstRow = (response.data as List).first as Map<String, dynamic>;
      log('First row: $firstRow');

      final data = firstRow['data'] as Map<String, dynamic>;
      log('Data: $data');

      final success = data['success'] as bool;
      log('Success: $success');

      return success;
    } catch (e) {
      log('Error setting pincode: $e');
      return false;
    }
  }

  Future<bool> updateEncryptedMasterkeyCheckValue(String checkValue) async {
    try {
      log('lib/services/supabase_service_user.dart: Calling updateEncryptedMasterkeyCheckValue');
      final response = await client.rpc('user_extra_update_encrypted_masterkey_check_value', params: {
        'input_check_value': checkValue,
      }).execute();

      log('lib/services/supabase_service_user.dart: Response status: ${response.status}');

      if (response.status != 200) {
        log('lib/services/supabase_service_user.dart: Error updating masterkey check value - status: ${response.status}');
        return false;
      }

      final List<dynamic> results = response.data as List<dynamic>;
      if (results.isEmpty) {
        log('lib/services/supabase_service_user.dart: Empty results from API');
        return false;
      }

      final Map<String, dynamic> firstRow = results[0] as Map<String, dynamic>;
      final Map<String, dynamic> data = firstRow['data'] as Map<String, dynamic>;
      final bool success = data['success'] as bool;

      log('lib/services/supabase_service_user.dart: Update result: ${data['message']}');
      return success;
    } catch (e) {
      log('lib/services/supabase_service_user.dart: Error updating masterkey check value: $e');
      return false;
    }
  }

  Future<bool> updateFCMToken(String fcmToken) async {
    try {
      log('lib/services/supabase_service_user.dart: Calling updateFCMToken');
      final response = await client.rpc('user_extra_update_fcm_token', params: {
        'input_fcm_token': fcmToken,
      }).execute();

      log('lib/services/supabase_service_user.dart: FCM Token response status: ${response.status}');

      if (response.status != 200) {
        log('lib/services/supabase_service_user.dart: Error updating FCM token - status: ${response.status}');
        return false;
      }

      final List<dynamic> results = response.data as List<dynamic>;
      if (results.isEmpty) {
        log('lib/services/supabase_service_user.dart: Empty results from FCM token API');
        return false;
      }

      final Map<String, dynamic> firstRow = results[0] as Map<String, dynamic>;
      final int statusCode = firstRow['status_code'] as int;

      log('lib/services/supabase_service_user.dart: FCM Token status_code: $statusCode');

      if (statusCode == 200) {
        final Map<String, dynamic> data = firstRow['data'] as Map<String, dynamic>;
        log('lib/services/supabase_service_user.dart: FCM Token update result: ${data['message']}');
        return true;
      } else {
        log('lib/services/supabase_service_user.dart: FCM Token update failed - status_code: $statusCode');
        return false;
      }
    } catch (e) {
      log('lib/services/supabase_service_user.dart: Error updating FCM token: $e');
      return false;
    }
  }
}
