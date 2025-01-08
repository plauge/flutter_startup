import '../exports.dart';
import '../models/contact.dart';

class SupabaseServiceContact {
  final SupabaseClient client;

  SupabaseServiceContact(this.client);

  Future<Contact?> loadContact(String contactId) async {
    try {
      final response = await client.rpc(
        'contact_load',
        params: {'input_contact_id': contactId},
      );

      print('Response from contact_load: $response');

      if (response == null) return null;
      if (response is List) {
        if (response.isEmpty) return null;
        final firstItem = response[0] as Map<String, dynamic>;
        final data = firstItem['data'] as Map<String, dynamic>;
        if (!data['success']) return null;
        final contactData = data['contact'] as Map<String, dynamic>;
        return Contact.fromJson(contactData);
      }

      final data = response['data'] as Map<String, dynamic>;
      if (!data['success']) return null;
      final contactData = data['contact'] as Map<String, dynamic>;
      return Contact.fromJson(contactData);
    } catch (e, st) {
      print('Error in loadContact: $e\n$st');
      rethrow;
    }
  }

  Future<bool> checkContactExists(String contactId) async {
    try {
      final response = await client.rpc(
        'contacts_do_exist',
        params: {'input_contact_id': contactId},
      );

      print('Response from contacts_do_exist: $response');

      if (response == null) return false;
      if (response is List) {
        if (response.isEmpty) return false;
        final firstItem = response[0] as Map<String, dynamic>;
        final data = firstItem['data'] as Map<String, dynamic>;
        return data['exists'] as bool;
      }

      final data = response['data'] as Map<String, dynamic>;
      return data['exists'] as bool;
    } catch (e, st) {
      print('Error in checkContactExists: $e\n$st');
      rethrow;
    }
  }

  Future<void> markAsVisited(String contactId) async {
    try {
      await client.rpc(
        'contacts_visited',
        params: {'input_contact_id': contactId},
      );
    } catch (e) {
      rethrow;
    }
  }
}
