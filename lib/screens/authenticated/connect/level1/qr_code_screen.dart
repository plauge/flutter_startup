import '../../../../exports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../providers/invitation_level1_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

class QRCodeScreen extends AuthenticatedScreen {
  QRCodeScreen({super.key});

  static Future<QRCodeScreen> create() async {
    final screen = QRCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Create new connection',
        backRoutePath: RoutePaths.connectLevel1,
      ),
      body: ref.watch(profileNotifierProvider).when(
            data: (profile) =>
                AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profile['profile_image'] != null &&
                                profile['profile_image'].toString().isNotEmpty
                            ? NetworkImage(profile['profile_image'])
                            : null,
                        child: (profile['profile_image'] == null ||
                                profile['profile_image'].toString().isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomText(
                        text:
                            '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
                        type: CustomTextType.head,
                        alignment: CustomTextAlignment.center,
                      ),
                      CustomText(
                        text: profile['company'] ?? '',
                        type: CustomTextType.bread,
                        alignment: CustomTextAlignment.center,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      Container(
                        padding: EdgeInsets.all(
                            AppDimensionsTheme.getMedium(context)),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: AppDimensionsTheme.getMedium(context),
                            ),
                            Gap(AppDimensionsTheme.getSmall(context)),
                            const CustomText(
                              text: 'Security Level 1',
                              type: CustomTextType.cardDescription,
                            ),
                          ],
                        ),
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      _QRPollingWidget(handleConfirm: _handleConfirm),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      const CustomText(
                        text:
                            'The person you want to connect with simply needs to scan this QR code in their own ID-Truster app.',
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
    );
  }

  void _handleConfirm(BuildContext context, Map<String, dynamic> invitation) {
    debugPrint('\n=== QR Code Screen - Handle Confirm ===');
    debugPrint('Full invitation data: $invitation');
    debugPrint('Data field exists: ${invitation.containsKey('data')}');
    if (invitation.containsKey('data')) {
      debugPrint('Data content: ${invitation['data']}');
      debugPrint(
          'Payload exists: ${invitation['data'].containsKey('payload')}');
      if (invitation['data'].containsKey('payload')) {
        debugPrint('Payload content: ${invitation['data']['payload']}');
        debugPrint(
            'Invitation ID exists: ${invitation['data']['payload'].containsKey('invitation_level_1_id')}');
      }
    }

    final String? invitationId =
        invitation['data']?['payload']?['invitation_level_1_id']?.toString();
    debugPrint('Extracted invitation ID: $invitationId');

    if (invitationId != null) {
      final String route =
          '${RoutePaths.confirmConnectionLevel1}?invite=$invitationId&key=null';
      debugPrint('Navigating to route: $route');
      context.go(route);
    } else {
      debugPrint('❌ No invitation ID found in data structure');
    }
  }
}

class _QRPollingWidget extends HookConsumerWidget {
  final void Function(BuildContext, Map<String, dynamic>) handleConfirm;

  const _QRPollingWidget({required this.handleConfirm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (pollingCount.value > 30) {
            timer.cancel();
            debugPrint(
                '\n=== Polling Timeout - Redirecting to Connect Level 1 ===');
            context.go(RoutePaths.connectLevel1);
            return;
          }

          ref.read(readInvitationLevel1Provider(invitationId).future).then(
            (response) {
              debugPrint('\n=== Polling Check ===');
              debugPrint('Response type: ${response.runtimeType}');
              debugPrint('Response: $response');

              final payload = response['payload'];
              final bool isLoaded = payload?['loaded'] ?? false;

              debugPrint('Payload: $payload');
              debugPrint('Is loaded: $isLoaded');

              if (isLoaded) {
                debugPrint('\n=== Loaded is TRUE - Calling handleConfirm ===');
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
              debugPrint('Error polling invitation: $error');
            },
          );
        },
      );
    }

    useEffect(() {
      void initializeQRCode() async {
        invitationController.value = const AsyncValue.loading();
        final secretKey =
            await ref.read(storageProvider.notifier).getCurrentUserToken();

        if (secretKey == null) {
          CustomSnackBar.show(
            context: context,
            text: 'Kunne ikke finde sikkerhedsnøgle. Prøv venligst igen.',
            type: CustomTextType.button,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          );
          return;
        }
        final commonToken = AESGCMEncryptionUtils.generateSecureToken();
        final commonKey = AESGCMEncryptionUtils.generateSecureToken();
        commonKeyState.value = commonKey;

        final encryptedInitiatorCommonToken =
            await AESGCMEncryptionUtils.encryptString(commonToken, secretKey);
        final encryptedReceiverCommonKey =
            await AESGCMEncryptionUtils.encryptString(commonToken, commonKey);

        debugPrint('\n=== Creating Level 1 Invitation ===');

        debugPrint('Creating invitation with params:');
        final InvitationParams params = (
          initiatorEncryptedKey: encryptedInitiatorCommonToken,
          receiverEncryptedKey: encryptedReceiverCommonKey,
          receiverTempName: "",
        );
        debugPrint('Params: $params');

        ref.read(createInvitationLevel1Provider(params).future).then(
          (value) {
            debugPrint('\n=== Invitation Created Successfully ===');
            debugPrint('Raw value type: ${value.runtimeType}');
            debugPrint('Raw value: $value');
            invitationController.value = AsyncValue.data(value);

            final String? invitationId =
                value['data']?['payload']?['invitation_level_1_id']?.toString();
            if (invitationId != null) {
              startPolling(invitationId);
            }
          },
          onError: (error, stack) {
            debugPrint('\n=== Error Creating Invitation ===');
            debugPrint('Error: $error');
            debugPrint('Stack trace: $stack');
            invitationController.value = AsyncValue.error(error, stack);
          },
        );
      }

      initializeQRCode();
      return null;
    }, []);

    return invitationController.value.when(
      data: (invitation) => QrImageView(
        data:
            'invite=${invitation['data']?['payload']?['invitation_level_1_id']}&key=${Uri.encodeComponent(commonKeyState.value ?? '')}',
        version: QrVersions.auto,
        size: 200.0,
      ),
      error: (e, _) => CustomText(
        text: 'Error creating invitation: $e',
        type: CustomTextType.info,
      ),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
