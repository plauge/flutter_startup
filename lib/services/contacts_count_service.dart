import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import '../exports.dart';

/// Service for calling the contacts_count Supabase RPC endpoint.
class ContactsCountService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  ContactsCountService(this._client);

  /// Calls the contacts_count RPC and returns the total_count as int.
  Future<int> getContactsCount() async {
    log('[services/contacts_count_service.dart][getContactsCount] Kalder RPC for contacts_count');

    try {
      final response = await _client.rpc('contacts_count');

      log('[services/contacts_count_service.dart][getContactsCount] Modtog response: $response');

      if (response == null) {
        log('❌ No response from contacts_count');
        return 0;
      }

      if (response is List) {
        if (response.isEmpty) {
          log('❌ Empty response list from contacts_count');
          return 0;
        }
        final firstItem = response[0] as Map<String, dynamic>;
        final data = firstItem['data'] as Map<String, dynamic>;

        if (!data['success']) {
          log('❌ Operation not successful: ${data['message']}');
          return 0;
        }

        final payload = data['payload'] as Map<String, dynamic>;
        final totalCount = payload['total_count'] as int;
        log('✅ Successfully retrieved contacts count - total_count: $totalCount, contacts: ${payload['contacts']}, invitation_level_1: ${payload['invitation_level_1']}, invitation_level_3: ${payload['invitation_level_3']}');
        return totalCount;
      }

      // Handle single object response
      final data = response['data'] as Map<String, dynamic>;
      if (!data['success']) {
        log('❌ Operation not successful: ${data['message']}');
        return 0;
      }

      final payload = data['payload'] as Map<String, dynamic>;
      final totalCount = payload['total_count'] as int;
      log('✅ Successfully retrieved contacts count - total_count: $totalCount, contacts: ${payload['contacts']}, invitation_level_1: ${payload['invitation_level_1']}, invitation_level_3: ${payload['invitation_level_3']}');
      return totalCount;
    } catch (e, st) {
      log('❌ Error in getContactsCount: $e\n$st');
      rethrow;
    }
  }
}

// File created: 2024-12-19 15:30:00
