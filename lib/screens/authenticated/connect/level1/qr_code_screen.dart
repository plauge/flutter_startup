import '../../../../exports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../providers/invitation_level1_provider.dart';

class QRCodeScreen extends AuthenticatedScreen {
  QRCodeScreen({super.key});

  static Future<QRCodeScreen> create() async {
    final screen = QRCodeScreen();
    return AuthenticatedScreen.create(screen);
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
          '${RoutePaths.confirmConnectionLevel1}?invite=$invitationId';
      debugPrint('Navigating to route: $route');
      context.go(route);
    } else {
      debugPrint('❌ No invitation ID found in data structure');
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return HookBuilder(
      builder: (context) {
        final profileAsync = ref.watch(profileNotifierProvider);
        final invitationController = useState<AsyncValue<Map<String, dynamic>>>(
          const AsyncValue.loading(),
        );

        useEffect(() {
          invitationController.value = const AsyncValue.loading();
          debugPrint('\n=== Creating Level 1 Invitation ===');

          debugPrint('Creating invitation with params:');
          final InvitationParams params = (
            initiatorEncryptedKey: "Test Key 1",
            receiverEncryptedKey: "Test Key 2",
            receiverTempName: "",
          );
          debugPrint('Params: $params');

          ref.read(createInvitationLevel1Provider(params).future).then(
            (value) {
              debugPrint('\n=== Invitation Created Successfully ===');
              debugPrint('Raw value type: ${value.runtimeType}');
              debugPrint('Raw value: $value');
              debugPrint('Data structure analysis:');
              debugPrint('Has data field: ${value.containsKey('data')}');
              if (value.containsKey('data')) {
                debugPrint('Data content: ${value['data']}');
                debugPrint(
                    'Has payload: ${value['data'].containsKey('payload')}');
                if (value['data'].containsKey('payload')) {
                  debugPrint('Payload content: ${value['data']['payload']}');
                  if (value['data']['payload'] is Map) {
                    final payload = value['data']['payload'] as Map;
                    debugPrint('Payload fields: ${payload.keys.join(', ')}');
                  }
                }
              }
              invitationController.value = AsyncValue.data(value);
            },
            onError: (error, stack) {
              debugPrint('\n=== Error Creating Invitation ===');
              debugPrint('Error: $error');
              debugPrint('Stack trace: $stack');
              invitationController.value = AsyncValue.error(error, stack);
            },
          );

          return null;
        }, []);

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            title: 'Create new connection',
            backRoutePath: RoutePaths.connectLevel1,
          ),
          body: profileAsync.when(
            data: (profile) => invitationController.value.when(
              data: (invitation) =>
                  AppTheme.getParentContainerStyle(context).applyToContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.grey,
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
                        QrImageView(
                          data: invitation['data']?['payload']
                                      ?['invitation_level_1_id']
                                  ?.toString() ??
                              'Error: No ID',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                        const CustomText(
                          text:
                              'The person you want to connect with simply needs to scan this QR code in their own EnigMe app. After scanning the QR code, please click continue.',
                          type: CustomTextType.bread,
                          alignment: CustomTextAlignment.center,
                        ),
                        Gap(AppDimensionsTheme.getLarge(context)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CustomButton(
                        text: 'Continue',
                        onPressed: () => _handleConfirm(context, invitation),
                      ),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: CustomText(
                  text: 'Error creating invitation: $e',
                  type: CustomTextType.info,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
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
      },
    );
  }
}
