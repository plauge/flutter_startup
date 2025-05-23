import '../../../../exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:logging/logging.dart';
import 'dart:convert';

class ConfirmConnectionLevel1Screen extends AuthenticatedScreen {
  ConfirmConnectionLevel1Screen({super.key});
  final _logger = Logger('ConfirmConnectionLevel1Screen');

  static Future<ConfirmConnectionLevel1Screen> create() async {
    developer.log('Creating ConfirmConnectionLevel1Screen');
    final screen = ConfirmConnectionLevel1Screen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleReject(BuildContext context) {
    _logger.info('🔄 Starting _handleReject');
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    _logger.fine('📝 Invitation ID in _handleReject: ${id ?? 'null'}');
    if (id != null) {
      _logger.info('✅ Valid ID found, proceeding with rejection');
      _performReject(context, id);
    } else {
      _logger.warning('❌ No valid ID found, rejection cancelled');
    }
  }

  void _performReject(BuildContext context, String id) {
    _logger.info('Starting _performReject with ID: $id');

    // Send API kald i baggrunden
    _logger.fine('Sending delete request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(deleteInvitationLevel1Provider(id));

    // Naviger til contacts siden med GoRouter
    _logger.fine('Navigating to contacts with GoRouter');
    context.go(RoutePaths.contacts);
  }

  void _handleConfirm(BuildContext context, String receiverEncryptedKey, String initiatorUserId, AuthenticatedState state) async {
    final String? invite_id = GoRouterState.of(context).queryParameters['invite'];
    String? common_key_parameter = GoRouterState.of(context).queryParameters['key'];
    final currentUserId = state.user.id;

    if (invite_id == null) {
      debugPrint('❌ No valid Level 1 invitation ID found, confirmation cancelled');
      return;
    }

    if (common_key_parameter == null) {
      debugPrint('❌ No common key parameter found, confirmation cancelled');
      common_key_parameter = '';
    } else {
      common_key_parameter = Uri.decodeComponent(common_key_parameter);
      if (common_key_parameter.length != 64) {
        debugPrint('❌ Invalid key length: ${common_key_parameter.length}, expected 64');
        CustomSnackBar.show(
          context: context,
          text: 'Ugyldig nøgle. Prøv venligst igen.',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        );
        return;
      }
    }

    try {
      if (initiatorUserId != currentUserId) {
        // receiverEncryptedKey
        //// common_key_parameter
        ///
        debugPrint('receiverEncryptedKey 1: $receiverEncryptedKey');
        debugPrint('common_key_parameter 2: $common_key_parameter');
        final decryptedReceiverKey = await AESGCMEncryptionUtils.decryptString(receiverEncryptedKey, common_key_parameter);

        // // Decode URL encoding first
        // final String urlDecodedKey = Uri.decodeComponent(receiverEncryptedKey);
        // debugPrint('✅ Successfully URL decoded common key');

        // // Then decode base64
        // final String decodedKey = utf8.decode(base64.decode(urlDecodedKey));
        // debugPrint('✅ Successfully base64 decoded common key');

        // // Validate key length
        // if (decodedKey.length != 64) {
        //   throw Exception('Decoded key must be exactly 64 characters long');
        // }

        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('decryptedReceiverKey: $decryptedReceiverKey');
        debugPrint('receiverEncryptedKey: $receiverEncryptedKey');
        debugPrint('common_key_parameter: $common_key_parameter');
        debugPrint('initiatorUserId: $initiatorUserId');
        debugPrint('currentUserId: $currentUserId');
        debugPrint('invite_id: $invite_id');
        // print flags to log
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        debugPrint('✅ Valid Level 1 invitation ID found, proceeding with confirmation');
        _performConfirm(
          context,
          invite_id,
          receiverEncryptedKey,
          decryptedReceiverKey,
          state,
          initiatorUserId,
        );
      } else {
        _performConfirm(context, invite_id, receiverEncryptedKey, '', state, initiatorUserId);
      }
    } catch (e) {
      debugPrint('❌ Error decoding common key: $e');
      CustomSnackBar.show(
        context: context,
        text: 'Der skete en fejl ved dekodning af nøglen. Prøv venligst igen.',
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 8),
      );
    }
  }

  void _performConfirm(
    BuildContext context,
    String id,
    String receiverEncryptedKey,
    String common_key_parameter,
    AuthenticatedState state,
    String initiatorUserId,
  ) async {
    final currentUserId = state.user.id;
    final ref = ProviderScope.containerOf(context);

    if (initiatorUserId != currentUserId) {
      //final decryptedKeyFromDatabase = await AESGCMEncryptionUtils.decryptString(receiverEncryptedKey, common_key_parameter);

      final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (secretKey == null) {
        CustomSnackBar.show(
          context: context,
          text: 'Kunne ikke finde sikkerhedsnøgle. Prøv venligst igen.',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        );
        return;
      }

      final encryptedKeyToDatabase = await AESGCMEncryptionUtils.encryptString(common_key_parameter, secretKey);

      await ref.read(invitationLevel1ConfirmProvider((
        invitationId: id,
        receiverEncryptedKey: encryptedKeyToDatabase,
      )).future);
    } else {
      await ref.read(invitationLevel1ConfirmProvider((
        invitationId: id,
        receiverEncryptedKey: '',
      )).future);
    }

    // Naviger til contacts siden med GoRouter
    _logger.fine('Navigating to contacts with GoRouter');
    context.go(RoutePaths.contacts);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    _logger.info('1. Starting buildAuthenticatedWidget');
    final routeState = GoRouterState.of(context);
    final String? id = routeState.queryParameters['invite'];
    final String? key = routeState.queryParameters['key'];
    _logger.fine('2. Got invite ID: $id');
    _logger.fine('3. Got key: $key');

    if (id == null) {
      return const Scaffold(
        body: Center(
          child: CustomText(
            text: 'Ingen invitation ID fundet',
            type: CustomTextType.bread,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const AuthenticatedAppBar(
        title: 'Bekræft Level 1 Forbindelse',
        backRoutePath: RoutePaths.contacts,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: ref.watch(readInvitationLevel1Provider(id)).when(
              data: (data) {
                _logger.info('🎯 Received data in ConfirmConnectionLevel1Screen for ID: $id');
                _logger.fine('🎯 Raw response data: $data');

                // Check if data is loaded
                final payload = data['payload'] as Map<String, dynamic>;
                if (payload['loaded'] == false) {
                  _logger.warning('❌ Data not loaded for ID: $id');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                          text: 'Du har ikke adgang til at se denne invitation',
                          type: CustomTextType.head,
                          alignment: CustomTextAlignment.center,
                        ),
                        Gap(AppDimensionsTheme.getMedium(context)),
                        const CustomText(
                          text: 'Kun den bruger som har oprettet invitationen kan se detaljerne.',
                          type: CustomTextType.bread,
                          alignment: CustomTextAlignment.center,
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        CustomButton(
                          text: 'Tilbage',
                          onPressed: () => context.go(RoutePaths.contacts),
                          buttonType: CustomButtonType.secondary,
                        ),
                      ],
                    ),
                  );
                }

                final String firstName = payload['first_name'] ?? 'Ukendt';
                final String lastName = payload['last_name'] ?? '';
                final String company = payload['company'] ?? 'Ukendt virksomhed';
                final String? profileImage = payload['profile_image'];
                final String tempName = payload['temp_name'] ?? '';

                // Extract additional data fields
                final DateTime createdAt = payload['created_at'] != null && payload['created_at'].toString().isNotEmpty ? DateTime.parse(payload['created_at'].toString()) : DateTime.now();
                final int receiverStatus = payload['receiver_status'] ?? 1;
                final bool receiverAccepted = payload['receiver_accepted'] ?? false;
                final bool initiatorAccepted = payload['initiator_accepted'] ?? false;
                final String receiverEncryptedKey = payload['receiver_encrypted_key'] ?? '';
                final String initiatorEncryptedKey = payload['initiator_encrypted_key'] ?? '';
                final String initiatorUserId = payload['initiator_user_id'] ?? '';
                final String? receiverUserId = payload['receiver_user_id'];

                // Sikkerhedstjek for at undgå null-fejl
                final bool isInitiator = initiatorUserId == state.user.id;
                final bool isreceiver = receiverUserId != null && receiverUserId == state.user.id;

                bool showRejectButton = true;
                bool showConfirmButton = false;

                final String text_no_confirmed_yet = "I mangler begge at bekræfte før at forbinde.";
                final String text_missing_your_confirm = "Kun du mangler bekræfte for at forbinde.";
                final String text_missing_connection_confirm = "Din kontakt har ikke bekræftet endnu";

                String text_output = text_no_confirmed_yet;

                if (isInitiator && !initiatorAccepted) {
                  showConfirmButton = true;
                }

                if (isInitiator && !receiverAccepted && !initiatorAccepted) {
                  text_output = text_no_confirmed_yet;
                }

                if (isInitiator && receiverAccepted && !initiatorAccepted) {
                  text_output = text_missing_your_confirm;
                }

                if (isInitiator && !receiverAccepted && initiatorAccepted) {
                  text_output = text_missing_connection_confirm;
                }

                if (!isInitiator && !receiverAccepted) {
                  showConfirmButton = true;
                }

                if (!isInitiator && !receiverAccepted && !initiatorAccepted) {
                  text_output = text_no_confirmed_yet;
                }

                if (!isInitiator && !receiverAccepted && initiatorAccepted) {
                  text_output = text_missing_your_confirm;
                }

                if (!isInitiator && receiverAccepted && !initiatorAccepted) {
                  text_output = text_missing_connection_confirm;
                }

                // Bemærk: Der er logiske fejl i betingelserne ovenfor, da !receiverAccepted og receiverAccepted ikke kan være sande samtidigt

                _logger.fine('🎯 Connection details:');
                _logger.fine('First name: $firstName');
                _logger.fine('Last name: $lastName');
                _logger.fine('Company: $company');
                _logger.fine('Profile image: $profileImage');
                _logger.fine('Created at: $createdAt');
                _logger.fine('receiver status: $receiverStatus');
                _logger.fine('receiver accepted: $receiverAccepted');
                _logger.fine('Initiator accepted: $initiatorAccepted');
                _logger.fine('Is initiator: $isInitiator');
                _logger.fine('Is receiver: $isreceiver');
                _logger.fine('Show reject button: $showRejectButton');
                _logger.fine('Show confirm button: $showConfirmButton');
                _logger.fine('receiver encrypted key length: ${receiverEncryptedKey.length}');
                _logger.fine('Initiator encrypted key length: ${initiatorEncryptedKey.length}');

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomText(
                                text: 'Bekræft Level 1 forbindelse',
                                type: CustomTextType.head,
                                alignment: CustomTextAlignment.center,
                              ),
                              Gap(AppDimensionsTheme.getMedium(context)),
                              if (profileImage?.isNotEmpty == true)
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(profileImage!),
                                )
                              else
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              Gap(AppDimensionsTheme.getMedium(context)),
                              CustomText(
                                text: '$firstName $lastName',
                                type: CustomTextType.head,
                                alignment: CustomTextAlignment.center,
                              ),
                              CustomText(
                                text: company,
                                type: CustomTextType.cardHead,
                                alignment: CustomTextAlignment.center,
                              ),
                              Gap(AppDimensionsTheme.getMedium(context)),
                              CustomText(
                                text: text_output,
                                type: CustomTextType.bread,
                                alignment: CustomTextAlignment.center,
                              ),
                              Gap(AppDimensionsTheme.getMedium(context)),
                              if (tempName.isNotEmpty) ...[
                                CustomText(
                                  text: 'Temp name: $tempName',
                                  type: CustomTextType.cardHead,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (showRejectButton) ...[
                            Expanded(
                              child: CustomButton(
                                text: 'Afvis',
                                onPressed: () => _handleReject(context),
                                buttonType: CustomButtonType.secondary,
                              ),
                            ),
                            Gap(AppDimensionsTheme.getMedium(context)),
                          ],
                          if (showConfirmButton)
                            Expanded(
                              child: CustomButton(
                                text: 'Bekræft',
                                onPressed: () => _handleConfirm(context, receiverEncryptedKey, initiatorUserId, state),
                                buttonType: CustomButtonType.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: CustomText(
                  text: 'Der skete en fejl 2: ${error.toString()}',
                  type: CustomTextType.bread,
                ),
              ),
            ),
      ),
    );
  }
}
