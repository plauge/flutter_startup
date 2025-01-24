import 'package:flutter_startup/exports.dart';
import 'package:flutter_startup/services/invitation_level3_service.dart';

final invitationLevel3ServiceProvider =
    Provider<InvitationLevel3Service>((ref) {
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
