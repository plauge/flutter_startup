import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/get_domain_owner_response.dart';
import '../utils/app_logger.dart';

/// Service for calling the get_domain_owner Supabase RPC endpoint.
class GetDomainOwnerService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  GetDomainOwnerService(this._client);

  /// Calls the get_domain_owner RPC with the given domain.
  Future<GetDomainOwnerResponse> getDomainOwner(String inputDomain) async {
    AppLogger.logSeparator('getDomainOwner - Service');
    log('[services/get_domain_owner_service.dart][getDomainOwner] Kalder RPC for domain: $inputDomain');
    final response = await _client.rpc(
      'get_domain_owner',
      params: {'input_domain': inputDomain},
    );
    log('[services/get_domain_owner_service.dart][getDomainOwner] Modtog response: $response');
    // Hvis din RPC returnerer en liste:
    return GetDomainOwnerResponse.fromJson((response as List).first as Map<String, dynamic>);
  }
}

// File created: 2024-06-08 13:00
