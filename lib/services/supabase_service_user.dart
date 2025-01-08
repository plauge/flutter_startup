part of 'supabase_service.dart';

extension SupabaseServiceUser on SupabaseService {
  Future<UserExtra?> getUserExtra() async {
    try {
      final user = client.auth.currentUser;
      print('=== getUserExtra Start ===');
      print('Current user: ${user?.email}');
      print('User ID: ${user?.id}');

      if (user == null) {
        print('❌ No authenticated user found');
        return null;
      }

      print('\n🔄 Calling user_extra_read database function...');

      final response = await client.rpc('user_extra_read').execute();

      print('\n📥 Response Details:');
      print('Raw response data: ${response.data}');

      final List<dynamic> results = response.data as List<dynamic>;
      if (results.isEmpty) {
        print('❌ No results returned from RPC');
        return null;
      }

      final Map<String, dynamic> result = results[0] as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>;

      if (!data['success']) {
        print('❌ Operation not successful');
        print('Error message: ${data['message']}');
        return null;
      }

      final payload = data['payload'];
      if (payload == null) {
        print('❌ No user extra data found');
        return null;
      }

      final userExtraJson = payload['user_extra'] as Map<String, dynamic>;
      print('\n📋 User Extra data:');
      print('Fields: ${userExtraJson.keys.join(', ')}');

      return UserExtra.fromJson(userExtraJson);
    } catch (e, stackTrace) {
      print('\n❌ Error in getUserExtra:');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace:\n$stackTrace');
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

  Future<bool> updateTermsConfirmed() async {
    try {
      final response = await client
          .rpc('user_extra_update_terms_confirmed')
          .select()
          .single();

      if (response is Map) {
        final success = response['data']?['success'] ?? false;
        if (success) {
          print('✅ Terms of service updated successfully');
        } else {
          print('❌ Failed to update terms of service');
        }
        return success;
      }
      return false;
    } catch (e) {
      print('Error updating terms confirmed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> completeOnboarding(
      String firstName, String lastName, String company) async {
    final response =
        await client.rpc('public_profiles_complete_onboarding', params: {
      'input_first_name': firstName,
      'input_last_name': lastName,
      'input_company': company,
    }).execute();

    if (response.status != 200) {
      throw Exception('Error completing onboarding.');
    }

    return response.data as Map<String, dynamic>;
  }
}
