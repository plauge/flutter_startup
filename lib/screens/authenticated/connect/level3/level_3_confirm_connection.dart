import '../../../../exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../services/i18n_service.dart';
import 'dart:io'; // Added for Platform detection

class Level3ConfirmConnectionScreen extends AuthenticatedScreen {
  Level3ConfirmConnectionScreen({super.key});

  static Future<Level3ConfirmConnectionScreen> create() async {
    debugPrint('Creating Level3ConfirmConnectionScreen');
    final screen = Level3ConfirmConnectionScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleReject(BuildContext context, String? invitationLevel3Id) {
    debugPrint('🔄 Starting Level 3 connection rejection flow');
    if (invitationLevel3Id == null) {
      debugPrint('❌ invitation_level_3_id is null! Cannot proceed with rejection.');
      CustomSnackBar.show(
        context: context,
        text: I18nService().t(
          'screen_level3_confirm_connection.error_missing_invitation_id',
          fallback: 'Error: invitation_level_3_id not found in response. Please contact support.',
        ),
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      );
      return;
    }
    debugPrint('📝 Level 3 invitation ID: $invitationLevel3Id');
    debugPrint('✅ Valid Level 3 invitation ID found, proceeding with rejection');
    _performReject(context, invitationLevel3Id);
  }

  void _performReject(BuildContext context, String id) {
    debugPrint('Starting _performReject with ID: $id');

    // Send API kald i baggrunden
    debugPrint('Sending delete request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(deleteInvitationLevel3Provider(id));

    // Naviger til contacts siden med GoRouter
    debugPrint('Navigating to contacts with GoRouter');
    context.go(RoutePaths.home);
  }

  void _handleConfirm(BuildContext context, String receiverEncryptedKey, String initiatorUserId, AuthenticatedState state, String? invitationLevel3Id) {
    debugPrint('🔄 Starting Level 3 connection confirmation flow');
    if (invitationLevel3Id == null) {
      debugPrint('❌ invitation_level_3_id is null! Cannot proceed with confirmation.');
      CustomSnackBar.show(
        context: context,
        text: I18nService().t(
          'screen_level3_confirm_connection.error_missing_invitation_id',
          fallback: 'Error: invitation_level_3_id not found in response. Please contact support.',
        ),
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      );
      return;
    }
    String? common_key_parameter = GoRouterState.of(context).queryParameters['key'];
    final currentUserId = state.user.id;

    debugPrint('📝 Level 3 invitation ID: $invitationLevel3Id');
    debugPrint('📝 Common key parameter: ${common_key_parameter ?? 'null'}');

    if (common_key_parameter == null) {
      debugPrint('❌ No common key parameter found, confirmation cancelled');
      common_key_parameter = '';
    }

    try {
      if (initiatorUserId != currentUserId) {
        // Decode URL encoding first
        final String urlDecodedKey = Uri.decodeComponent(common_key_parameter);
        debugPrint('✅ Successfully URL decoded common key');

        // Then decode base64
        final String decodedKey = utf8.decode(base64.decode(urlDecodedKey));
        debugPrint('✅ Successfully base64 decoded common key');

        // Validate key length
        if (decodedKey.length != 64) {
          throw Exception('Decoded key must be exactly 64 characters long');
        }

        debugPrint('✅ Valid Level 3 invitation ID found, proceeding with confirmation');
        _performConfirm(
          context,
          invitationLevel3Id,
          receiverEncryptedKey,
          decodedKey,
          state,
          initiatorUserId,
        );
      } else {
        _performConfirm(context, invitationLevel3Id, receiverEncryptedKey, '', state, initiatorUserId);
      }
    } catch (e) {
      debugPrint('❌ Error decoding common key: $e');
      CustomSnackBar.show(
        context: context,
        text: I18nService().t('screen_contacts_connect_level_3_confirm.error_key_decoding', fallback: 'An error occurred while decoding the key. Please try again.'),
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
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
    debugPrint('Starting _performConfirm with ID: $id');
    debugPrint('Starting _performConfirm with common_key_parameter: $common_key_parameter');
    debugPrint('Starting _performConfirm with receiverEncryptedKey: $receiverEncryptedKey');

    // Send API kald i baggrunden
    debugPrint('Sending confirm request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    //ref.read(invitationLevel3ConfirmProvider(id));

    if (initiatorUserId != currentUserId) {
      final decryptedKeyFromDatabase = await AESGCMEncryptionUtils.decryptString(receiverEncryptedKey, common_key_parameter);

      final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (secretKey == null) {
        CustomSnackBar.show(
          context: context,
          text: I18nService().t('screen_contacts_connect_level_3_confirm.error_no_secret_key', fallback: 'Could not find secret key. Please try again.'),
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final encryptedKeyToDatabase = await AESGCMEncryptionUtils.encryptString(decryptedKeyFromDatabase, secretKey);

      await ref.read(invitationLevel3ConfirmProvider((
        invitationId: id,
        receiverEncryptedKey: encryptedKeyToDatabase,
      )).future);
    } else {
      await ref.read(invitationLevel3ConfirmProvider((
        invitationId: id,
        receiverEncryptedKey: '',
      )).future);
    }

    // Naviger til contacts siden med GoRouter
    debugPrint('Navigating to contacts with GoRouter');
    context.go(RoutePaths.home);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    debugPrint('1. Starting buildAuthenticatedWidget');
    final String? invite_code = GoRouterState.of(context).queryParameters['invite'];
    debugPrint('2. Got invite code: $invite_code');

    if (invite_code == null) {
      return Scaffold(
        body: Center(
          child: CustomText(
            text: I18nService().t('screen_contacts_connect_level_3_confirm.error_no_invitation_id', fallback: 'No invitation ID found'),
            type: CustomTextType.bread,
          ),
        ),
      );
    }

    // Determine if invite_code is a new code (starts with "idti") or old UUID
    final bool isNewCode = invite_code.toLowerCase().startsWith('idti');
    debugPrint('3. Invite code type: ${isNewCode ? "new code (idti)" : "old UUID"}');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_header', fallback: 'Confirm connection'),
        backRoutePath: RoutePaths.home,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: isNewCode
              ? ref.watch(readInvitationLevel3V2Provider(invite_code)).when(
                    data: (data) => _buildDataWidget(context, ref, state, data, invite_code, isNewCode),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: CustomText(
                        text: I18nService().t('screen_contacts_connect_level_3_confirm.error_invitation_deleted', fallback: 'Invitation has been deleted'),
                        type: CustomTextType.bread,
                      ),
                    ),
                  )
              : ref.watch(readInvitationLevel3Provider(invite_code)).when(
                    data: (data) => _buildDataWidget(context, ref, state, data, invite_code, isNewCode),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: CustomText(
                        text: I18nService().t('screen_contacts_connect_level_3_confirm.error_invitation_deleted', fallback: 'Invitation has been deleted'),
                        type: CustomTextType.bread,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildDataWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
    Map<String, dynamic> data,
    String invite_code,
    bool isNewCode,
  ) {
    // Extract invitation_level_3_id from response
    // For new code (idti), extract from response
    // For old UUID, use invite_code directly
    String? invitationLevel3Id;
    if (isNewCode) {
      invitationLevel3Id = data['invitation_level_3_id'] as String?;
      // Fallback to other possible field names if needed
      if (invitationLevel3Id == null) {
        invitationLevel3Id = data['invitation_id'] as String?;
      }
      if (invitationLevel3Id == null) {
        invitationLevel3Id = data['id'] as String?;
      }
    } else {
      // For old UUID, use invite_code directly as invitation_level_3_id
      invitationLevel3Id = invite_code;
    }

    // Log whether ID was found
    if (invitationLevel3Id == null) {
      debugPrint('⚠️ invitation_level_3_id not found in response! Will show error when user clicks buttons.');
    }

    // Store the ID (may be null - we'll handle error when user clicks buttons)
    final String? finalInvitationLevel3Id = invitationLevel3Id;

    // Check if data is loaded or receiver_user_id matches specific UUID
    if (data['loaded'] == false || data['receiver_user_id'] == 'c406d385-5ba3-41eb-82db-dc250cf32e24') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: CustomText(
                text: I18nService().t('screen_contacts_connect_level_3_confirm.error_no_user_confirmed', fallback: 'No user has confirmed the connection yet.'),
                type: CustomTextType.bread,
              ),
            ),
          ),
          Builder(
            builder: (context) {
              final deleteButton = Padding(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                child: CustomButton(
                  key: const Key('level3_connection_delete_button'),
                  text: I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_delete_button', fallback: 'Delete'),
                  onPressed: () => _handleReject(context, finalInvitationLevel3Id),
                  buttonType: CustomButtonType.secondary,
                ),
              );

              return Platform.isAndroid ? SafeArea(top: false, child: deleteButton) : deleteButton;
            },
          ),
        ],
      );
    }

    final String firstName = data['first_name'] ?? 'Ukendt';
    final String lastName = data['last_name'] ?? '';
    final String company = data['company'] ?? 'Ukendt virksomhed';
    final String? profileImage = data['profile_image'];
    final String tempName = data['temp_name'] ?? '';

    // Extract additional data fields
    final DateTime createdAt = DateTime.parse(data['created_at'] ?? '');
    final int receiverStatus = data['receiver_status'] ?? 1;
    final bool receiverAccepted = data['receiver_accepted'] ?? false;
    final bool initiatorAccepted = data['initiator_accepted'] ?? false;
    final String receiverEncryptedKey = data['receiver_encrypted_key'] ?? '';
    final String initiatorEncryptedKey = data['initiator_encrypted_key'] ?? '';
    final String initiatorUserId = data['initiator_user_id'] ?? '';
    final String? receiverUserId = data['receiver_user_id'];

    // Sikkerhedstjek for at undgå null-fejl
    final bool isInitiator = initiatorUserId == state.user.id;
    final bool isreceiver = receiverUserId != null && receiverUserId == state.user.id;

    bool showRejectButton = true;
    bool showConfirmButton = false;

    final String text_no_confirmed_yet = I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_no_confirmed_yet', fallback: 'I need both of us to confirm before connecting.');
    final String text_missing_your_confirm = I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_missing_your_confirm', fallback: 'You need to confirm before connecting.');
    final String text_missing_connection_confirm = I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_missing_connection_confirm', fallback: 'Your contact has not confirmed yet');

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

    debugPrint('🎯 Connection details:');
    debugPrint('Created at: $createdAt');
    debugPrint('receiver status: $receiverStatus');
    debugPrint('receiver accepted: $receiverAccepted');
    debugPrint('Initiator accepted: $initiatorAccepted');
    debugPrint('Is initiator: $isInitiator');
    debugPrint('Is receiver: $isreceiver');
    debugPrint('Show reject button: $showRejectButton');
    debugPrint('Show confirm button: $showConfirmButton');
    debugPrint('receiver encrypted key length: ${receiverEncryptedKey.length}');
    debugPrint('Initiator encrypted key length: ${initiatorEncryptedKey.length}');

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
                  CustomText(
                    text: I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_header', fallback: 'Confirm connection'),
                    type: CustomTextType.head,
                    alignment: CustomTextAlignment.center,
                  ),
                  const SizedBox(height: 16),
                  if (profileImage?.isNotEmpty == true)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: CachedNetworkImageProvider(profileImage!),
                    )
                  else
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  if (tempName.isNotEmpty) ...[
                    CustomText(
                      text: 'Temp name: $tempName',
                      type: CustomTextType.cardHead,
                      alignment: CustomTextAlignment.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  CustomText(
                    text: text_output,
                    type: CustomTextType.bread,
                    alignment: CustomTextAlignment.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Builder(
          builder: (context) {
            final connectionButtons = Padding(
              padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showRejectButton) ...[
                    Expanded(
                      child: CustomButton(
                        key: const Key('level3_connection_reject_button'),
                        text: I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_reject_button', fallback: 'Reject'),
                        onPressed: () => _handleReject(context, finalInvitationLevel3Id),
                        buttonType: CustomButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (showConfirmButton)
                    Expanded(
                      child: CustomButton(
                        key: const Key('level3_connection_confirm_button'),
                        text: I18nService().t('screen_contacts_connect_level_3_confirm.confirm_connection_confirm_button', fallback: 'Confirm'),
                        onPressed: () => _handleConfirm(context, receiverEncryptedKey, initiatorUserId, state, finalInvitationLevel3Id),
                        buttonType: CustomButtonType.primary,
                      ),
                    ),
                ],
              ),
            );

            return Platform.isAndroid ? SafeArea(top: false, child: connectionButtons) : connectionButtons;
          },
        ),
      ],
    );
  }
}

// Created: 2024-12-19 12:15:00
