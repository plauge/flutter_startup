import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/security_app_status_response.dart';
import '../services/security_app_status_service.dart';
import 'supabase_provider.dart';
import '../utils/app_logger.dart';

part 'generated/security_app_status_provider.g.dart';

/// Provider for fetching app status data from Supabase without caching.
@riverpod
Future<SecurityAppStatusResponse> securityAppStatus(ref) async {
  final log = scopedLogger(LogCategory.provider);

  log('[providers/security_app_status_provider.dart][securityAppStatus] Starting provider for security app status - NO CACHE');

  try {
    final client = ref.read(supabaseClientProvider);
    log('[providers/security_app_status_provider.dart][securityAppStatus] Got Supabase client');

    final service = SecurityAppStatusService(client);
    log('[providers/security_app_status_provider.dart][securityAppStatus] Created service, calling getAppStatus...');

    final result = await service.getAppStatus();
    log('[providers/security_app_status_provider.dart][securityAppStatus] Successfully got app status');

    return result;
  } catch (error, stackTrace) {
    log('[providers/security_app_status_provider.dart][securityAppStatus] Error in provider: $error');
    log('[providers/security_app_status_provider.dart][securityAppStatus] Stack trace: $stackTrace');
    rethrow;
  }
}

// File created: 2025-01-06 15:30
