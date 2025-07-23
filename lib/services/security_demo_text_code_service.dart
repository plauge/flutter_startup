import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class SecurityDemoTextCodeService {
  static final log = scopedLogger(LogCategory.service);

  final SupabaseClient _client;

  SecurityDemoTextCodeService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  /// Sends a demo text code to the user
  ///
  /// Returns true if status code is 200, false otherwise
  Future<bool> sendDemoTextCode() async {
    try {
      log('SecurityDemoTextCodeService.sendDemoTextCode: Starting demo text code request');
      log('SecurityDemoTextCodeService.sendDemoTextCode: Calling RPC function: security_send_user_demo_text_code');

      final response = await _client.rpc('security_send_user_demo_text_code');

      log('SecurityDemoTextCodeService.sendDemoTextCode: Raw response received');
      log('SecurityDemoTextCodeService.sendDemoTextCode: Response type: ${response.runtimeType}');
      log('SecurityDemoTextCodeService.sendDemoTextCode: Response content: ${response.toString()}');

      if (response == null) {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Response is null');
        return false;
      }

      if (response is List && response.isEmpty) {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Response is empty list');
        return false;
      }

      // Handle different response types
      Map<String, dynamic> responseData;
      if (response is List) {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Response is a list with ${response.length} elements');
        responseData = response[0] as Map<String, dynamic>;
        log('SecurityDemoTextCodeService.sendDemoTextCode: Using first element: ${responseData.toString()}');
      } else if (response is Map<String, dynamic>) {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Response is a map');
        responseData = response;
      } else {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Unexpected response type: ${response.runtimeType}');
        return false;
      }

      // Extract status code
      if (!responseData.containsKey('status_code')) {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Response missing status_code field');
        log('SecurityDemoTextCodeService.sendDemoTextCode: Available keys: ${responseData.keys.toList()}');
        return false;
      }

      final statusCode = responseData['status_code'];
      log('SecurityDemoTextCodeService.sendDemoTextCode: Status code value: $statusCode (type: ${statusCode.runtimeType})');

      // Convert to int if needed
      int statusCodeInt;
      if (statusCode is int) {
        statusCodeInt = statusCode;
      } else if (statusCode is String) {
        statusCodeInt = int.tryParse(statusCode) ?? -1;
        log('SecurityDemoTextCodeService.sendDemoTextCode: Converted string status code to int: $statusCodeInt');
      } else {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Unable to parse status code: $statusCode');
        return false;
      }

      log('SecurityDemoTextCodeService.sendDemoTextCode: Final status code - $statusCodeInt');

      // Check if status code is 200
      if (statusCodeInt == 200) {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Demo text code sent successfully');
        return true;
      } else {
        log('SecurityDemoTextCodeService.sendDemoTextCode: Failed with status code: $statusCodeInt');

        // Log additional error information if available
        if (responseData.containsKey('message')) {
          log('SecurityDemoTextCodeService.sendDemoTextCode: Error message: ${responseData['message']}');
        }
        if (responseData.containsKey('error')) {
          log('SecurityDemoTextCodeService.sendDemoTextCode: Error details: ${responseData['error']}');
        }

        return false;
      }
    } catch (e, stackTrace) {
      log('SecurityDemoTextCodeService.sendDemoTextCode: Exception occurred - $e');
      log('SecurityDemoTextCodeService.sendDemoTextCode: Exception type: ${e.runtimeType}');
      log('SecurityDemoTextCodeService.sendDemoTextCode: Stack trace: $stackTrace');
      return false;
    }
  }
}

// File created: 2024-12-31 16:30:00
