import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/get_domain_owner_response.dart';
import '../services/get_domain_owner_service.dart';
import 'supabase_provider.dart';

part 'generated/get_domain_owner_provider.g.dart';

/// Provider for fetching domain owner data from Supabase.
@riverpod
class GetDomainOwnerNotifier extends _$GetDomainOwnerNotifier {
  @override
  Future<GetDomainOwnerResponse> build(String inputDomain) async {
    final client = ref.read(supabaseClientProvider);
    final service = GetDomainOwnerService(client);
    return await service.getDomainOwner(inputDomain);
  }
}

// File created: 2024-06-08 13:00
