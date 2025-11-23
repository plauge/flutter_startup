import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/security_app_status_response.dart';
import '../utils/app_logger.dart';

/// Service for calling the security_get_app_status Supabase RPC endpoint.
class SecurityAppStatusService {
  static final log = scopedLogger(LogCategory.service);

  final dynamic _client; // Accept LoggedSupabaseClient or SupabaseClient

  SecurityAppStatusService(this._client);

  /// Calls the security_get_app_status RPC endpoint.
  Future<SecurityAppStatusResponse> getAppStatus() async {
    log('[services/security_app_status_service.dart][getAppStatus] Starting - Kalder RPC security_get_app_status');

    try {
      log('[services/security_app_status_service.dart][getAppStatus] Client authenticated: ${_client.auth.currentUser != null}');
      log('[services/security_app_status_service.dart][getAppStatus] Making RPC call...');

      final response = await _client.rpc('security_get_app_status');

      log('[services/security_app_status_service.dart][getAppStatus] RPC call completed');
      log('[services/security_app_status_service.dart][getAppStatus] Response type: ${response.runtimeType}');
      log('[services/security_app_status_service.dart][getAppStatus] Response: $response');

      if (response == null) {
        throw Exception('Response is null');
      }

      if (response is! List) {
        throw Exception('Response is not a List, got: ${response.runtimeType}');
      }

      if (response.isEmpty) {
        throw Exception('Response list is empty');
      }

      final firstItem = response.first;
      log('[services/security_app_status_service.dart][getAppStatus] First item: $firstItem');

      // RPC returnerer en liste med et object
      return SecurityAppStatusResponse.fromJson(firstItem as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      log('[services/security_app_status_service.dart][getAppStatus] PostgrestException - Code: ${error.code}, Message: ${error.message}, Details: ${error.details}');
      throw Exception('Database error: ${error.message}');
    } catch (error) {
      log('[services/security_app_status_service.dart][getAppStatus] General error: $error');
      log('[services/security_app_status_service.dart][getAppStatus] Error type: ${error.runtimeType}');
      throw Exception('Failed to get app status: $error');
    }
  }
}

// File created: 2025-01-06 15:30
