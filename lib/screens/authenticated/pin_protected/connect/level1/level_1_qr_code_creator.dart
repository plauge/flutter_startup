import '../../../../../exports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../../providers/invitation_level1_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../../../../../services/i18n_service.dart';

class Level1QrCodeCreator extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  Level1QrCodeCreator({super.key}) : super(face_id_protected: true);

  static Future<Level1QrCodeCreator> create() async {
    final screen = Level1QrCodeCreator();
    return AuthenticatedScreen.create(screen);
  }

  Future<void> handleImageSelection(BuildContext context, WidgetRef ref) async {
    AppLogger.logSeparator('handleImageSelection');
    // TODO: Implement image selection logic
    AppLogger.logSeparator('handleImageSelection');
    log('Image selection not implemented yet');
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    AppLogger.logSeparator('Widget buildAuthenticatedWidget');
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts_connect_create_qr_code.create_qr_code_header', fallback: 'Create new connection'),
        backRoutePath: RoutePaths.level1CreateOrScanQr,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: ref.watch(profileNotifierProvider).when(
              data: (profile) => AppTheme.getParentContainerStyle(context).applyToContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Gap(AppDimensionsTheme.getLarge(context)),
                        CustomProfileImage(
                          profileImageProvider: profile['profile_image'],
                          handleImageSelection: handleImageSelection,
                          showEdit: false,
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        Text(
                          '${profile['first_name']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: AppDimensionsTheme.isSmallScreen(context) ? 22.4 : 28, // 20% smaller on small screens
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A3751),
                            decoration: TextDecoration.none,
                            height: AppDimensionsTheme.isSmallScreen(context) ? 25.6 / 22.4 : 32 / 28, // line-height proportionally adjusted
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${profile['last_name']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: AppDimensionsTheme.isSmallScreen(context) ? 22.4 : 28, // 20% smaller on small screens
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A3751),
                            decoration: TextDecoration.none,
                            height: AppDimensionsTheme.isSmallScreen(context) ? 25.6 / 22.4 : 32 / 28, // line-height proportionally adjusted
                          ),
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        CustomText(
                          text: profile['company'],
                          type: CustomTextType.info400,
                          alignment: CustomTextAlignment.center,
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        _QRPollingWidget(handleConfirm: _handleConfirm),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        CustomText(
                          text: I18nService().t('screen_contacts_connect_create_qr_code.create_qr_code_body', fallback: 'The person you want to connect with simply needs to scan this QR code in their own ID-Truster app.'),
                          type: CustomTextType.bread,
                          alignment: CustomTextAlignment.center,
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                      ],
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: CustomText(
                  text: 'Error loading profile: $e',
                  type: CustomTextType.info,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
      ),
    );
  }

  void _handleConfirm(BuildContext context, Map<String, dynamic> invitation) {
    log('\n=== QR Code Screen - Handle Confirm ===');
    log('Full invitation data: $invitation');
    log('Data field exists: ${invitation.containsKey('data')}');
    if (invitation.containsKey('data')) {
      log('Data content: ${invitation['data']}');
      log('Payload exists: ${invitation['data'].containsKey('payload')}');
      if (invitation['data'].containsKey('payload')) {
        log('Payload content: ${invitation['data']['payload']}');
        log('Invitation ID exists: ${invitation['data']['payload'].containsKey('invitation_level_1_id')}');
      }
    }

    final String? invitationId = invitation['data']?['payload']?['invitation_level_1_id']?.toString();
    log('Extracted invitation ID: $invitationId');

    if (invitationId != null) {
      final String route = '${RoutePaths.level1ConfirmConnection}?invite=$invitationId'; // &key=null
      log('Navigating to route: $route');
      context.go(route);
    } else {
      log('❌ No invitation ID found in data structure');
    }
  }
}

class _QRPollingWidget extends HookConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);
  final void Function(BuildContext, Map<String, dynamic>) handleConfirm;

  const _QRPollingWidget({required this.handleConfirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.logSeparator('Widget build');
    final invitationController = useState<AsyncValue<Map<String, dynamic>>>(
      const AsyncValue.loading(),
    );
    final pollingTimer = useState<Timer?>(null);
    final pollingCount = useState<int>(0);
    final commonKeyState = useState<String?>(null);

    void startPolling(String invitationId) {
      pollingTimer.value?.cancel();
      pollingTimer.value = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          pollingCount.value++;
          if (pollingCount.value > 60) {
            timer.cancel();
            log('\n=== Polling Timeout - Redirecting to Connect Level 1 ===');
            context.go(RoutePaths.level1CreateOrScanQr);
            return;
          }

          ref.read(readInvitationLevel1Provider(invitationId).future).then(
            (response) {
              log('\n=== Polling Check ===');
              log('Response type: ${response.runtimeType}');
              log('Response: $response');

              final payload = response['payload'];
              final bool isLoaded = payload?['loaded'] ?? false;

              log('Payload: $payload');
              log('Is loaded: $isLoaded');

              if (isLoaded) {
                log('\n=== Loaded is TRUE - Calling handleConfirm ===');
                timer.cancel();
                handleConfirm(context, {
                  'data': {
                    'payload': {
                      'invitation_level_1_id': invitationId,
                    },
                  },
                });
              }
            },
            onError: (error) {
              log('Error polling invitation: $error');
            },
          );
        },
      );
    }

    useEffect(() {
      void initializeQRCode() async {
        AppLogger.logSeparator('initializeQRCode');
        invitationController.value = const AsyncValue.loading();
        final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();

        if (secretKey == null) {
          CustomSnackBar.show(
            context: context,
            text: I18nService().t('screen_contacts_connect_create_qr_code.create_qr_code_error_no_secret_key', fallback: 'Could not find secret key. Please try again.'),
            type: CustomTextType.button,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          );
          return;
        }
        final commonToken = AESGCMEncryptionUtils.generateSecureToken();
        final commonKey = AESGCMEncryptionUtils.generateSecureToken();
        commonKeyState.value = commonKey;

        final encryptedInitiatorCommonToken = await AESGCMEncryptionUtils.encryptString(commonToken, secretKey);
        final encryptedReceiverCommonKey = await AESGCMEncryptionUtils.encryptString(commonToken, commonKey);

        log('\n=== Creating Level 1 Invitation ===');

        log('Creating invitation with params:');
        final InvitationParams params = (
          initiatorEncryptedKey: encryptedInitiatorCommonToken,
          receiverEncryptedKey: encryptedReceiverCommonKey,
          receiverTempName: "",
        );
        log('Params: $params');

        ref.read(createInvitationLevel1Provider(params).future).then(
          (value) {
            log('\n=== Invitation Created Successfully ===');
            log('Raw value type: ${value.runtimeType}');
            log('Raw value: $value');
            invitationController.value = AsyncValue.data(value);

            final String? invitationId = value['data']?['payload']?['invitation_level_1_id']?.toString();
            if (invitationId != null) {
              startPolling(invitationId);
            }
          },
          onError: (error, stack) {
            log('\n=== Error Creating Invitation ===');
            log('Error: $error');
            log('Stack trace: $stack');
            invitationController.value = AsyncValue.error(error, stack);
          },
        );
      }

      initializeQRCode();
      return null;
    }, []);

    return invitationController.value.when(
      data: (invitation) => QrImageView(
        data: 'invite=${invitation['data']?['payload']?['invitation_level_1_id']}&key=${Uri.encodeComponent(commonKeyState.value ?? '')}',
        version: QrVersions.auto,
        size: AppDimensionsTheme.isSmallScreen(context) ? 160.0 : 200.0, // 20% smaller on small screens
      ),
      error: (e, _) => CustomText(
        text: 'Error creating invitation: $e',
        type: CustomTextType.info,
      ),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

// Created: 2024-12-20 16:45:00
