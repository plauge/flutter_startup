import 'package:flutter_startup/exports.dart';
import 'package:flutter_startup/services/invitation_level1_service.dart';

final invitationLevel1ServiceProvider =
    Provider<InvitationLevel1Service>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return InvitationLevel1Service(client);
});

final createInvitationLevel1Provider = AutoDisposeFutureProviderFamily<
    String,
    ({
      String initiatorEncryptedKey,
      String receiverEncryptedKey,
      String receiverTempName,
    })>((ref, params) async {
  final service = ref.watch(invitationLevel1ServiceProvider);
  return service.createInvitation(
    initiatorEncryptedKey: params.initiatorEncryptedKey,
    receiverEncryptedKey: params.receiverEncryptedKey,
    receiverTempName: params.receiverTempName,
  );
});
