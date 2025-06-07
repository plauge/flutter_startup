import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/get_domain_owner_response.dart';
import '../services/get_domain_owner_service.dart';
import 'supabase_provider.dart';
import '../utils/app_logger.dart';

part 'generated/get_domain_owner_provider.g.dart';

/// Provider for fetching domain owner data from Supabase.
@riverpod
class GetDomainOwnerNotifier extends _$GetDomainOwnerNotifier {
  static final log = scopedLogger(LogCategory.provider);
  @override
  Future<GetDomainOwnerResponse> build(String inputDomain) async {
    AppLogger.logSeparator('getDomainOwner - Provider');
    log('[providers/get_domain_owner_provider.dart][build] Kalder provider med inputDomain: $inputDomain');
    final client = ref.read(supabaseClientProvider);
    final service = GetDomainOwnerService(client);
    return await service.getDomainOwner(inputDomain);
  }
}

// File created: 2024-06-08 13:00
