import 'package:id_truster/exports.dart';
import 'package:id_truster/services/invitation_level1_service.dart';

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
