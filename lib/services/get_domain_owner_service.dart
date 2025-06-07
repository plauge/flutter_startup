import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/get_domain_owner_response.dart';
import '../utils/app_logger.dart';

/// Service for calling the get_domain_owner Supabase endpoint.
class GetDomainOwnerService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  GetDomainOwnerService(this._client);

  /// Calls the get_domain_owner endpoint with the given domain.
  Future<GetDomainOwnerResponse> getDomainOwner(String inputDomain) async {
    log('Calling get_domain_owner for domain: $inputDomain | file: get_domain_owner_service.dart');
    final response = await _client.functions.invoke(
      'get_domain_owner',
      body: {'input_domain': inputDomain},
    );
    if (response.status == 200) {
      final List<dynamic> jsonList = json.decode(response.data as String);
      return GetDomainOwnerResponse.fromJson(jsonList.first as Map<String, dynamic>);
    } else {
      log('Error from get_domain_owner: \\${response.status} | file: get_domain_owner_service.dart');
      throw Exception('Failed to get domain owner: Status \\${response.status}');
    }
  }
}

// File created: 2024-06-08 13:00
