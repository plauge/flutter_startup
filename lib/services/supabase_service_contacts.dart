part of 'supabase_service.dart';

extension SupabaseServiceContacts on SupabaseService {
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

  Future<List<Contact>> loadRecentContacts() async {
    try {
      print('\n=== loadRecentContacts Start ===');
      final response = await client.rpc('contacts_last_used').execute();

      if (response.status != 200) {
        print('Error loading recent contacts: Status ${response.status}');
        return [];
      }

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

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();

      print('\nParsed Recent Contacts:');
      for (var contact in contacts) {
        print('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      print('=== loadRecentContacts End ===\n');

      return contacts;
    } catch (e) {
      print('Error loading recent contacts: $e');
      return [];
    }
  }

  Future<List<Contact>> loadNewContacts() async {
    try {
      print('\n=== loadNewContacts Start ===');
      final response = await client.rpc('contacts_new').execute();

      if (response.status != 200) {
        print('Error loading new contacts: Status ${response.status}');
        return [];
      }

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

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();

      print('\nParsed New Contacts:');
      for (var contact in contacts) {
        print('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      print('=== loadNewContacts End ===\n');

      return contacts;
    } catch (e) {
      print('Error loading new contacts: $e');
      return [];
    }
  }
}
