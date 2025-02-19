import 'package:idtruster/exports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthValidationResponse {
  final int statusCode;
  final bool success;
  final String message;
  final Map<String, dynamic> payload;
  final String logId;
  const AuthValidationResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.payload,
    required this.logId,
  });
  factory AuthValidationResponse.fromJson(Map<String, dynamic> json) {
    return AuthValidationResponse(
      statusCode: json['status_code'] as int,
      success: json['success'] as bool,
      message: json['message'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      logId: json['log_id'] as String,
    );
  }
}

class AuthValidationService {
  final SupabaseClient _client;
  AuthValidationService(this._client);
  Future<AuthValidationResponse> validateSession() async {
    try {
      final response = await _client.rpc('auth_validation_session').execute();

      if (response.data == null) {
        throw Exception('Failed to validate session: No response');
      }

      final Map<String, dynamic> result = response.data as Map<String, dynamic>;

      if (result.containsKey('data')) {
        return AuthValidationResponse.fromJson(result['data']);
      }

      return AuthValidationResponse.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }
}
