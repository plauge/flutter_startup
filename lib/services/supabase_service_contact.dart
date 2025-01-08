import '../exports.dart';

class SupabaseServiceContact {
  final SupabaseClient client;

  const SupabaseServiceContact(this.client);

  Future<void> markContactAsVisited(String contactId) async {
    await client.rpc(
      'contacts_visited',
      params: {'input_contact_id': contactId},
    );
  }
}
