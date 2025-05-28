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
      log('Response type: ${response.data.runtimeType}');
      log('Response data: ${response.data.toString()}');

      Map<String, dynamic> data;

      try {
        // Handle both response formats
        if (response.data is List<dynamic>) {
          log('Processing as List<dynamic> format');
          // Format: [{status_code: 200, data: {...}}]
          final List<dynamic> responseList = response.data as List<dynamic>;
          if (responseList.isEmpty) {
            log('Empty response list');
            return [];
          }
          log('First item type: ${responseList[0].runtimeType}');
          final responseMap = responseList[0] as Map<String, dynamic>;
          log('ResponseMap keys: ${responseMap.keys}');
          data = responseMap['data'] as Map<String, dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          log('Processing as Map<String, dynamic> format');
          // Format: {status_code: 200, data: {...}}
          final responseMap = response.data as Map<String, dynamic>;
          log('ResponseMap keys: ${responseMap.keys}');
          data = responseMap['data'] as Map<String, dynamic>;
        } else {
          log('Unknown response format: ${response.data.runtimeType}');
          return null;
        }
      } catch (e) {
        log('Error parsing response format: $e');
        return null;
      }

      if (!data['success']) {
        log('Operation not successful: ${data['message']}');
        return null;
      }

      log('\nPayload:');
      log('Payload data: ${data['payload'].toString()}');

      final payload = data['payload'] as List<dynamic>;
      log('Payload count: ${payload.length}');

      final contacts = <Contact>[];
      for (int i = 0; i < payload.length; i++) {
        try {
          final json = payload[i] as Map<String, dynamic>;
          log('Processing contact $i: ${json.keys}');

          // Ensure the json has is_new field, default to 0 if not present
          final Map<String, dynamic> contactJson = Map<String, dynamic>.from(json);
          if (!contactJson.containsKey('is_new')) {
            contactJson['is_new'] = 0;
          }

          // Map API field names to expected field names
          if (contactJson.containsKey('contact_id')) {
            contactJson['contactId'] = contactJson['contact_id'];
          }
          if (contactJson.containsKey('first_name')) {
            contactJson['firstName'] = contactJson['first_name'];
          }
          if (contactJson.containsKey('last_name')) {
            contactJson['lastName'] = contactJson['last_name'];
          }
          if (contactJson.containsKey('contact_type')) {
            contactJson['contactType'] = contactJson['contact_type'];
          }
          if (contactJson.containsKey('profile_image')) {
            contactJson['profileImage'] = contactJson['profile_image'];
          }

          log('Mapped contact $i: ${contactJson.keys}');
          final contact = Contact.fromJson(contactJson);
          contacts.add(contact);
          log('Successfully parsed contact $i: ${contact.firstName} ${contact.lastName}');
        } catch (e) {
          log('Error parsing contact $i: $e');
          continue;
        }
      }

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
      log('Response type: ${response.data.runtimeType}');
      log('Response data: ${response.data.toString()}');

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
      log('Payload data: ${data['payload'].toString()}');

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
