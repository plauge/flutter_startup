import '../../../../../exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:logging/logging.dart';
import 'dart:convert';
import '../../../../../providers/get_contact_by_users_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../services/i18n_service.dart';
import 'dart:io'; // Added for Platform detection

class Level1ConfirmConnectionScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  Level1ConfirmConnectionScreen({super.key}) : super(face_id_protected: true);
  final _logger = Logger('Level1ConfirmConnectionScreen');

  static Future<Level1ConfirmConnectionScreen> create() async {
    log('Creating Level1ConfirmConnectionScreen');
    final screen = Level1ConfirmConnectionScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleReject(BuildContext context) {
    AppLogger.logSeparator('Widget _handleReject');
    log('🔄 Starting _handleReject');
    final String? id = GoRouterState.of(context).queryParameters['invite'];
    log('📝 Invitation ID in _handleReject: ${id ?? 'null'}');
    if (id != null) {
      log('✅ Valid ID found, proceeding with rejection');
      _performReject(context, id);
    } else {
      _logger.warning('❌ No valid ID found, rejection cancelled');
    }
  }

  void _performReject(BuildContext context, String id) {
    AppLogger.logSeparator(' _performReject');
    log('Starting _performReject with ID: $id');

    // Send API kald i baggrunden
    log('Sending delete request for ID: $id');
    final ref = ProviderScope.containerOf(context);
    ref.read(deleteInvitationLevel1Provider(id));

    // Naviger til contacts siden med GoRouter
    log('Navigating to contacts with GoRouter');
    context.go(RoutePaths.home);
  }

  void _handleConfirm(BuildContext context, String receiverEncryptedKey, String initiatorUserId, AuthenticatedState state) async {
    AppLogger.logSeparator('_handleConfirm');
    log('🔄 Starting _handleConfirm from level_1_confirm_connection.dart');

    final String? invite_id = GoRouterState.of(context).queryParameters['invite'];
    String? common_key_parameter = GoRouterState.of(context).queryParameters['key'];
    final currentUserId = state.user.id;

    // Log initial parameters with data map
    log('📋 Initial parameters extracted', {
      'invite_id': invite_id ?? 'null',
      'common_key_parameter_length': common_key_parameter?.length ?? 0,
      'receiverEncryptedKey_length': receiverEncryptedKey.length,
      'initiatorUserId': initiatorUserId,
      'currentUserId': currentUserId,
      'is_same_user': initiatorUserId == currentUserId,
    });

    if (invite_id == null) {
      log('❌ Validation failed: No invitation ID found');
      return;
    }

    if (common_key_parameter == null) {
      log('⚠️ No common key parameter found, setting empty string');
      common_key_parameter = '';
    } else {
      try {
        log('🔄 Attempting to decode common key parameter', {
          'original_length': common_key_parameter.length,
          'original_value': common_key_parameter,
        });

        common_key_parameter = Uri.decodeComponent(common_key_parameter);

        log('✅ Successfully decoded common key parameter', {
          'decoded_length': common_key_parameter.length,
          'decoded_value': common_key_parameter,
        });

        if (common_key_parameter.length != 64) {
          log('❌ Invalid decoded key length', {
            'actual_length': common_key_parameter.length,
            'expected_length': 64,
          });
          CustomSnackBar.show(
            context: context,
            text: 'Ugyldig nøgle. Prøv venligst igen.',
            type: CustomTextType.button,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          );
          return;
        }
      } catch (e, stackTrace) {
        log('❌ Error decoding common key parameter', {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
        });
        CustomSnackBar.show(
          context: context,
          text: 'Fejl ved dekodning af nøgleparameter. Prøv venligst igen.',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        );
        return;
      }
    }

    try {
      if (initiatorUserId != currentUserId) {
        log('🔄 Processing as receiver (different user)', {
          'initiatorUserId': initiatorUserId,
          'currentUserId': currentUserId,
          'receiverEncryptedKey_length': receiverEncryptedKey.length,
          'common_key_parameter_length': common_key_parameter.length,
        });

        log('🔓 Attempting AES decryption');
        final decryptedReceiverKey = await AESGCMEncryptionUtils.decryptString(receiverEncryptedKey, common_key_parameter);

        log('✅ Successfully decrypted receiver key', {
          'decryptedKey_length': decryptedReceiverKey.length,
          'decryptedKey_value': decryptedReceiverKey,
        });

        log('🔄 Calling _performConfirm with decrypted key');
        _performConfirm(
          context,
          invite_id,
          receiverEncryptedKey,
          decryptedReceiverKey,
          state,
          initiatorUserId,
        );
      } else {
        log('🔄 Processing as initiator (same user)', {
          'initiatorUserId': initiatorUserId,
          'currentUserId': currentUserId,
        });

        log('🔄 Calling _performConfirm without decryption');
        _performConfirm(context, invite_id, receiverEncryptedKey, '', state, initiatorUserId);
      }
    } catch (e, stackTrace) {
      log('❌ Critical error in _handleConfirm', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'error_type': e.runtimeType.toString(),
      });
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
    AppLogger.logSeparator('_performConfirm');
    log('🔄 Starting _performConfirm from level_1_confirm_connection.dart');

    final currentUserId = state.user.id;
    final ref = ProviderScope.containerOf(context);

    log('📋 _performConfirm parameters', {
      'id': id,
      'receiverEncryptedKey_length': receiverEncryptedKey.length,
      'common_key_parameter_length': common_key_parameter.length,
      'currentUserId': currentUserId,
      'initiatorUserId': initiatorUserId,
      'is_receiver': initiatorUserId != currentUserId,
    });

    if (initiatorUserId != currentUserId) {
      log('🔄 Processing as receiver - getting secret key and encrypting');

      try {
        final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();

        log('🔐 Secret key retrieval result', {
          'secret_key_found': secretKey != null,
          'secret_key_length': secretKey?.length ?? 0,
        });

        if (secretKey == null) {
          log('❌ No secret key found in storage');
          CustomSnackBar.show(
            context: context,
            text: 'Kunne ikke finde sikkerhedsnøgle. Prøv venligst igen.',
            type: CustomTextType.button,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          );
          return;
        }

        log('🔓 Attempting to encrypt common_key_parameter with secret key');
        final encryptedKeyToDatabase = await AESGCMEncryptionUtils.encryptString(common_key_parameter, secretKey);

        log('✅ Successfully encrypted key for database', {
          'encrypted_key_length': encryptedKeyToDatabase.length,
        });

        log('🔄 Calling invitationLevel1ConfirmProvider with encrypted key');
        await ref.read(invitationLevel1ConfirmProvider((
          invitationId: id,
          receiverEncryptedKey: encryptedKeyToDatabase,
        )).future);

        log('✅ Successfully called invitationLevel1ConfirmProvider (receiver path)');
      } catch (e, stackTrace) {
        log('❌ Error in receiver confirmation process', {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'error_type': e.runtimeType.toString(),
        });
        CustomSnackBar.show(
          context: context,
          text: 'Der skete en fejl under bekræftelsen. Prøv venligst igen.',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        );
        return;
      }
    } else {
      log('🔄 Processing as initiator - calling provider with empty key');

      try {
        await ref.read(invitationLevel1ConfirmProvider((
          invitationId: id,
          receiverEncryptedKey: '',
        )).future);

        log('✅ Successfully called invitationLevel1ConfirmProvider (initiator path)');
      } catch (e, stackTrace) {
        log('❌ Error in initiator confirmation process', {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'error_type': e.runtimeType.toString(),
        });
        CustomSnackBar.show(
          context: context,
          text: 'Der skete en fejl under bekræftelsen. Prøv venligst igen.',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        );
        return;
      }
    }

    log('🔄 Navigating to contacts with GoRouter');
    context.go(RoutePaths.home);
    log('✅ Navigation completed successfully');
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    AppLogger.logSeparator('Widget buildAuthenticatedWidget');
    log('1. Starting buildAuthenticatedWidget');
    final routeState = GoRouterState.of(context);
    final String? id = routeState.queryParameters['invite'];
    final String? key = routeState.queryParameters['key'];
    log('2. Got invite ID: $id');
    log('3. Got key: $key');

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

    String decodedKey = 'N/A';
    if (key != null) {
      try {
        decodedKey = Uri.decodeComponent(key);
      } catch (e) {
        log('Error decoding key parameter: $e');
        decodedKey = key; // Use the raw key if decoding fails
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts_connect_confirm.confirm_connection_header', fallback: 'Confirm Level 1 Connection'),
        backRoutePath: RoutePaths.home,
        onBeforeBack: () async {
          _handleReject(context);
        },
        onBeforeHome: () async {
          _handleReject(context);
        },
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: ref.watch(readInvitationLevel1Provider(id)).when(
                data: (data) {
                  log('🎯 Received data in Level1ConfirmConnectionScreen for ID: $id');
                  log('🎯 Raw response data: $data');

                  // Check if data is loaded
                  final payload = data['payload'] as Map<String, dynamic>;
                  if (payload['loaded'] == false) {
                    _logger.warning('❌ Data not loaded for ID: $id');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: I18nService().t('screen_contacts_connect_confirm.confirm_connection_no_access', fallback: 'You do not have access to see this invitation'),
                            type: CustomTextType.head,
                            alignment: CustomTextAlignment.center,
                          ),
                          Gap(AppDimensionsTheme.getMedium(context)),
                          CustomText(
                            text: I18nService().t('screen_contacts_connect_confirm.confirm_connection_no_access_body', fallback: 'Only the user who created the invitation can see the details.'),
                            type: CustomTextType.bread,
                            alignment: CustomTextAlignment.center,
                          ),
                          Gap(AppDimensionsTheme.getLarge(context)),
                          CustomButton(
                            text: I18nService().t('screen_contacts_connect_confirm.confirm_connection_back_button', fallback: 'Back'),
                            onPressed: () => context.go(RoutePaths.home),
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

                  final String text_no_confirmed_yet = I18nService().t('screen_contacts_connect_confirm.confirm_connection_no_confirmed_yet', fallback: 'I need both of us to confirm before connecting.');
                  final String text_missing_your_confirm = I18nService().t('screen_contacts_connect_confirm.confirm_connection_missing_your_confirm', fallback: 'You need to confirm before connecting.');
                  final String text_missing_connection_confirm = I18nService().t('screen_contacts_connect_confirm.confirm_connection_missing_connection_confirm', fallback: 'Your contact has not confirmed yet');

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

                  log('🎯 Connection details:');
                  log('First name: $firstName');
                  log('Last name: $lastName');
                  log('Company: $company');
                  log('Profile image: $profileImage');
                  log('Created at: $createdAt');
                  log('receiver status: $receiverStatus');
                  log('receiver accepted: $receiverAccepted');
                  log('Initiator accepted: $initiatorAccepted');
                  log('Is initiator: $isInitiator');
                  log('Is receiver: $isreceiver');
                  log('Show reject button: $showRejectButton');
                  log('Show confirm button: $showConfirmButton');
                  log('receiver encrypted key length: ${receiverEncryptedKey.length}');
                  log('Initiator encrypted key length: ${initiatorEncryptedKey.length}');

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
                                  text: I18nService().t('screen_contacts_connect_confirm.confirm_connection_header', fallback: 'Confirm Level 1 Connection'),
                                  type: CustomTextType.head,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                if (profileImage?.isNotEmpty == true)
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: CachedNetworkImageProvider(profileImage!),
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
                                // CustomText(
                                //   text: 'Key: $decodedKey',
                                //   type: CustomTextType.bread,
                                //   alignment: CustomTextAlignment.center,
                                // ),
                                // Gap(AppDimensionsTheme.getMedium(context)),
                                // CustomText(
                                //   text: 'Invite: $id',
                                //   type: CustomTextType.bread,
                                //   alignment: CustomTextAlignment.center,
                                // ),
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
                                      key: const Key('level1_connection_reject_button'),
                                      text: I18nService().t('screen_contacts_connect_confirm.confirm_connection_reject_button', fallback: 'Reject'),
                                      onPressed: () => _handleReject(context),
                                      buttonType: CustomButtonType.secondary,
                                    ),
                                  ),
                                  Gap(AppDimensionsTheme.getMedium(context)),
                                ],
                                if (showConfirmButton)
                                  Expanded(
                                    child: CustomButton(
                                      key: const Key('level1_connection_confirm_button'),
                                      text: I18nService().t('screen_contacts_connect_confirm.confirm_connection_confirm_button', fallback: 'Confirm'),
                                      onPressed: () => _handleConfirm(context, receiverEncryptedKey, initiatorUserId, state),
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
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _ErrorHandler(
                  context: context,
                  ref: ref,
                  state: state,
                  inviteId: id,
                ),
              ),
        ),
      ),
    );
  }
}

class _ErrorHandler extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;
  final AuthenticatedState state;
  final String inviteId;

  const _ErrorHandler({
    required this.context,
    required this.ref,
    required this.state,
    required this.inviteId,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get user IDs from the invitation data to determine which contact to navigate to
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getInvitationData(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          final payload = data['payload'] as Map<String, dynamic>?;

          if (payload != null) {
            final String initiatorUserId = payload['initiator_user_id'] ?? '';
            final String? receiverUserId = payload['receiver_user_id'];
            final String currentUserId = state.user.id;

            // Find the user ID that is NOT the current user
            String? otherUserId;
            if (initiatorUserId.isNotEmpty && initiatorUserId != currentUserId) {
              otherUserId = initiatorUserId;
            } else if (receiverUserId != null && receiverUserId != currentUserId) {
              otherUserId = receiverUserId;
            }

            if (otherUserId != null) {
              return ref.watch(getContactByUsersProvider(otherUserId)).when(
                    data: (contactId) {
                      if (contactId != null) {
                        // Navigate to contact verification
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go('/contact-verification/$contactId');
                        });
                      } else {
                        // If no contact ID found, navigate to contacts
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go(RoutePaths.home);
                        });
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) {
                      // If getting contact ID fails, navigate to contacts
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go(RoutePaths.home);
                      });
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
            }
          }
        }

        // If we can't determine the other user, navigate to contacts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RoutePaths.home);
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Map<String, dynamic>?> _getInvitationData() async {
    try {
      final service = ref.read(invitationLevel1ServiceProvider);
      return await service.readInvitation(inviteId);
    } catch (e) {
      return null;
    }
  }
}

// Created: 2024-12-20 16:15:00
