part of 'supabase_service.dart';

extension SupabaseServiceContacts on SupabaseService {
  static final log = scopedLogger(LogCategory.service);

  Future<List<Contact>?> loadContacts() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      log('\n=== loadContacts Start ===');
      log('Loading contacts for user: ${user.email}');

      final response = await client.rpc('contacts_load_all').execute();

      if (response.status != 200) {
        log('Error loading contacts: Status ${response.status}');
        return null;
      }

      log('\nRaw Response:');
      log(response.data);

      final List<dynamic> responseList = response.data as List<dynamic>;
      if (responseList.isEmpty) {
        log('Empty response list');
        return [];
      }

      final responseMap = responseList[0] as Map<String, dynamic>;
      final data = responseMap['data'] as Map<String, dynamic>;

      if (!data['success']) {
        log('Operation not successful: ${data['message']}');
        return null;
      }

      log('\nPayload:');
      log(data['payload']);

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload.map((json) {
        // Ensure the json has is_new field, default to 0 if not present
        final Map<String, dynamic> contactJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (!contactJson.containsKey('is_new')) {
          contactJson['is_new'] = 0;
        }
        return Contact.fromJson(contactJson);
      }).toList();

      log('\nParsed Contacts:');
      for (var contact in contacts) {
        log('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      log('=== loadContacts End ===\n');

      return contacts;
    } catch (e, stack) {
      log('Error loading contacts: $e');
      log('Stack trace: $stack');
      return null;
    }
  }

  Future<List<Contact>> loadStarredContacts() async {
    try {
      log('\n=== loadStarredContacts Start ===');
      final response = await client.rpc('contacts_load_star').execute();

      if (response.status != 200) {
        log('Error loading starred contacts: Status ${response.status}');
        return [];
      }

      log('\nRaw Response:');
      log(response.data);

      final List<dynamic> responseList = response.data as List<dynamic>;
      if (responseList.isEmpty) {
        log('Empty response list');
        return [];
      }

      final responseMap = responseList[0] as Map<String, dynamic>;
      final data = responseMap['data'] as Map<String, dynamic>;

      if (!data['success']) {
        log('Operation not successful: ${data['message']}');
        return [];
      }

      log('\nPayload:');
      log(data['payload']);

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload.map((json) {
        // Ensure the json has is_new field, default to 0 if not present
        final Map<String, dynamic> contactJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (!contactJson.containsKey('is_new')) {
          contactJson['is_new'] = 0;
        }
        return Contact.fromJson(contactJson);
      }).toList();

      log('\nParsed Starred Contacts:');
      for (var contact in contacts) {
        log('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      log('=== loadStarredContacts End ===\n');

      return contacts;
    } catch (e) {
      log('Error loading starred contacts: $e');
      return [];
    }
  }

  Future<List<Contact>> loadRecentContacts() async {
    try {
      log('\n=== loadRecentContacts Start ===');
      final response = await client.rpc('contacts_last_used').execute();

      if (response.status != 200) {
        log('Error loading recent contacts: Status ${response.status}');
        return [];
      }

      final List<dynamic> responseList = response.data as List<dynamic>;
      if (responseList.isEmpty) {
        log('Empty response list');
        return [];
      }

      final responseMap = responseList[0] as Map<String, dynamic>;
      final data = responseMap['data'] as Map<String, dynamic>;

      if (!data['success']) {
        log('Operation not successful: ${data['message']}');
        return [];
      }

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload.map((json) {
        // Ensure the json has is_new field, default to 0 if not present
        final Map<String, dynamic> contactJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (!contactJson.containsKey('is_new')) {
          contactJson['is_new'] = 0;
        }
        return Contact.fromJson(contactJson);
      }).toList();

      log('\nParsed Recent Contacts:');
      for (var contact in contacts) {
        log('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      log('=== loadRecentContacts End ===\n');

      return contacts;
    } catch (e) {
      log('Error loading recent contacts: $e');
      return [];
    }
  }

  Future<List<Contact>> loadNewContacts() async {
    try {
      log('\n=== loadNewContacts Start ===');
      final response = await client.rpc('contacts_new').execute();

      if (response.status != 200) {
        log('Error loading new contacts: Status ${response.status}');
        return [];
      }

      final List<dynamic> responseList = response.data as List<dynamic>;
      if (responseList.isEmpty) {
        log('Empty response list');
        return [];
      }

      final responseMap = responseList[0] as Map<String, dynamic>;
      final data = responseMap['data'] as Map<String, dynamic>;

      if (!data['success']) {
        log('Operation not successful: ${data['message']}');
        return [];
      }

      final payload = data['payload'] as List<dynamic>;
      final contacts = payload.map((json) {
        // Ensure the json has is_new field, default to 0 if not present
        final Map<String, dynamic> contactJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
        if (!contactJson.containsKey('is_new')) {
          contactJson['is_new'] = 0;
        }
        return Contact.fromJson(contactJson);
      }).toList();

      log('\nParsed New Contacts:');
      for (var contact in contacts) {
        log('- ${contact.firstName} ${contact.lastName} (${contact.email})');
      }
      log('=== loadNewContacts End ===\n');

      return contacts;
    } catch (e) {
      log('Error loading new contacts: $e');
      return [];
    }
  }
}
