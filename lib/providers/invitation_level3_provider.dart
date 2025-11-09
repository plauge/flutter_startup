import 'package:idtruster/exports.dart';
import 'package:idtruster/services/invitation_level3_service.dart';

final invitationLevel3ServiceProvider = Provider<InvitationLevel3Service>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InvitationLevel3Service(client);
});

final createInvitationLevel3Provider = AutoDisposeFutureProviderFamily<
    String,
    ({
      String initiatorEncryptedKey,
      String receiverEncryptedKey,
      String receiverTempName,
    })>((ref, params) async {
  final service = ref.watch(invitationLevel3ServiceProvider);
  return service.createInvitation(
    initiatorEncryptedKey: params.initiatorEncryptedKey,
    receiverEncryptedKey: params.receiverEncryptedKey,
    receiverTempName: params.receiverTempName,
  );
});

final readInvitationLevel3Provider = AutoDisposeFutureProviderFamily<Map<String, dynamic>, String>((ref, invitationId) async {
  final service = ref.watch(invitationLevel3ServiceProvider);
  return service.readInvitation(invitationId);
});

final readInvitationLevel3V2Provider = AutoDisposeFutureProviderFamily<Map<String, dynamic>, String>((ref, saltInvitationLevel3Code) async {
  final service = ref.watch(invitationLevel3ServiceProvider);
  return service.readInvitationV2(saltInvitationLevel3Code);
});

final deleteInvitationLevel3Provider = AutoDisposeFutureProviderFamily<void, String>(
  (ref, invitationId) async {
    final service = ref.watch(invitationLevel3ServiceProvider);
    return service.deleteInvitation(invitationId);
  },
);

final invitationLevel3ConfirmProvider = FutureProvider.autoDispose.family<void, ({String invitationId, String receiverEncryptedKey})>((ref, params) async {
  final service = ref.read(invitationLevel3ServiceProvider);
  return service.confirmInvitation(
    params.invitationId,
    params.receiverEncryptedKey,
  );
});

final invitationLevel3WaitingForInitiatorProvider = AutoDisposeFutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(invitationLevel3ServiceProvider);
  return service.waitingForInitiator();
});

final createInvitationLevel3V2Provider = AutoDisposeFutureProviderFamily<
    Map<String, String>,
    ({
      String initiatorEncryptedKey,
      String receiverEncryptedKey,
      String receiverTempName,
    })>((ref, params) async {
  final service = ref.watch(invitationLevel3ServiceProvider);
  return service.createInvitationV2(
    initiatorEncryptedKey: params.initiatorEncryptedKey,
    receiverEncryptedKey: params.receiverEncryptedKey,
    receiverTempName: params.receiverTempName,
  );
});
