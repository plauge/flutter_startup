import 'package:idtruster/exports.dart';
import 'package:idtruster/services/invitation_level1_service.dart';

final invitationLevel1ServiceProvider =
    Provider<InvitationLevel1Service>((ref) {
  final client = ref.watch(supabaseClientProvider);
  debugPrint('Creating InvitationLevel1Service instance');
  return InvitationLevel1Service(client);
});

typedef InvitationParams = ({
  String initiatorEncryptedKey,
  String receiverEncryptedKey,
  String receiverTempName,
});

final createInvitationLevel1Provider =
    AutoDisposeFutureProviderFamily<Map<String, dynamic>, InvitationParams>(
        (ref, params) async {
  debugPrint(
      'Creating Level 1 invitation with receiver: ${params.receiverTempName}');
  final service = ref.watch(invitationLevel1ServiceProvider);
  return service.createInvitation(
    initiatorEncryptedKey: params.initiatorEncryptedKey,
    receiverEncryptedKey: params.receiverEncryptedKey,
    receiverTempName: params.receiverTempName,
  );
});

final readInvitationLevel1Provider =
    AutoDisposeFutureProviderFamily<Map<String, dynamic>, String>(
        (ref, invitationId) async {
  final service = ref.watch(invitationLevel1ServiceProvider);
  return service.readInvitation(invitationId);
});

final deleteInvitationLevel1Provider =
    AutoDisposeFutureProviderFamily<void, String>(
  (ref, invitationId) async {
    final service = ref.watch(invitationLevel1ServiceProvider);
    return service.deleteInvitation(invitationId);
  },
);

final invitationLevel1ConfirmProvider = FutureProvider.autoDispose
    .family<void, ({String invitationId, String receiverEncryptedKey})>(
        (ref, params) async {
  final service = ref.read(invitationLevel1ServiceProvider);
  return service.confirmInvitation(
      params.invitationId, params.receiverEncryptedKey);
});

final invitationLevel1WaitingForInitiatorProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(invitationLevel1ServiceProvider);
  return service.waitingForInitiator();
});
