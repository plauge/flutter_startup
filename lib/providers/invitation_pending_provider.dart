import 'package:idtruster/exports.dart';
import 'package:idtruster/services/invitation_pending_service.dart';

final invitationPendingServiceProvider =
    Provider<InvitationPendingService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InvitationPendingService(client);
});

final invitationPendingProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(invitationPendingServiceProvider);
  return service.getPendingInvitations();
});
