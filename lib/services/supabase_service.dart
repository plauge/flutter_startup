import 'dart:convert';
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

  Future<List<Contact>?> loadContacts() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      print('\n=== loadContacts Start ===');
      print('Loading contacts for user: ${user.email}');

      final response = await client.rpc('contacts_load_all').execute();

      if (response.status != 200) {
        print('Error loading contacts: Status ${response.status}');
        return null;
      }

      print('\nRaw Response:');
      print(response.data);

      final List<dynamic> responseList = response.data as List<dynamic>;
      if (responseList.isEmpty) {
        print('Empty response list');
        return [];
      }

      final responseMap = responseList[0] as Map<String, dynamic>;
      final data = responseMap['data'] as Map<String, dynamic>;

      if (!data['success']) {
        print('Operation not successful: ${data['message']}');
        return null;
      }

      print('\nPayload:');
      print(data['payload']);

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();

      print('\nParsed Contacts:');
      for (var contact in contacts) {
        print('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      print('=== loadContacts End ===\n');

      return contacts;
    } catch (e, stack) {
      print('Error loading contacts: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<List<Contact>> loadStarredContacts() async {
    try {
      print('\n=== loadStarredContacts Start ===');
      final response = await client.rpc('contacts_load_star').execute();

      if (response.status != 200) {
        print('Error loading starred contacts: Status ${response.status}');
        return [];
      }

      print('\nRaw Response:');
      print(response.data);

      final List<dynamic> responseList = response.data as List<dynamic>;
      if (responseList.isEmpty) {
        print('Empty response list');
        return [];
      }

      final responseMap = responseList[0] as Map<String, dynamic>;
      final data = responseMap['data'] as Map<String, dynamic>;

      if (!data['success']) {
        print('Operation not successful: ${data['message']}');
        return [];
      }

      print('\nPayload:');
      print(data['payload']);

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();

      print('\nParsed Starred Contacts:');
      for (var contact in contacts) {
        print('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      print('=== loadStarredContacts End ===\n');

      return contacts;
    } catch (e) {
      print('Error loading starred contacts: $e');
      return [];
    }
  }
}
