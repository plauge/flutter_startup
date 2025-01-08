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

  Future<bool> contactExists(String contactId) async {
    final response = await client.rpc(
      'contacts_do_exist',
      params: {'input_contact_id': contactId},
    ).execute();

    if (response.status != 200) {
      throw Exception('Error checking contact existence');
    }

    final List<dynamic> responseList = response.data as List<dynamic>;
    if (responseList.isEmpty) {
      return false;
    }

    final responseMap = responseList[0] as Map<String, dynamic>;
    final data = responseMap['data'] as Map<String, dynamic>;
    return data['exists'] as bool;
  }
}
