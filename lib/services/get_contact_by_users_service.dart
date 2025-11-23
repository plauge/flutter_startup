import 'package:idtruster/exports.dart';

class GetContactByUsersService {
  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient
  static final log = scopedLogger(LogCategory.service);

  GetContactByUsersService(this._client) {
    log('GetContactByUsersService initialized');
  }

  Future<String?> getContactByUsers(String inputContactId) async {
    log('Calling get_contacts_by_users RPC for contact ID: $inputContactId');
    try {
      final response = await _client.rpc(
        'get_contacts_by_users',
        params: {
          'input_contact_id': inputContactId,
        },
      );

      log('Raw response: $response');

      if (response == null) {
        log('❌ Response is null');
        return null;
      }

      if (response is List && response.isNotEmpty) {
        final firstItem = response.first as Map<String, dynamic>;
        log('📋 First item from list: $firstItem');

        final statusCode = firstItem['status_code'] as int?;
        if (statusCode != 200) {
          log('❌ Invalid status code: $statusCode');
          return null;
        }

        final data = firstItem['data'] as Map<String, dynamic>?;
        if (data == null) {
          log('❌ No data field in response');
          return null;
        }

        final success = data['success'] as bool?;
        if (success != true) {
          log('❌ Operation not successful: ${data['message']}');
          return null;
        }

        final contactId = data['contact_id'] as String?;
        log('✅ Successfully extracted contact_id: $contactId');
        return contactId;
      }

      log('❌ Invalid response format');
      return null;
    } catch (e) {
      log('❌ Error getting contact by users: $e');
      return null;
    }
  }
}

// Created: 2024-12-28 11:30:00
