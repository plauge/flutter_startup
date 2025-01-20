import '../../../../exports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class QRCodeScreen extends AuthenticatedScreen {
  QRCodeScreen({super.key});

  static Future<QRCodeScreen> create() async {
    final screen = QRCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleConfirm() {
    // TODO: Implement confirm action
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

        return Scaffold(
          appBar: const AuthenticatedAppBar(
            title: 'Create new connection',
            backRoutePath: RoutePaths.connectLevel1,
          ),
          body: profileAsync.when(
            data: (profile) =>
                AppTheme.getParentContainerStyle(context).applyToContainer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/placeholder.png'),
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
                        data: 'demo-qr-code-123456789',
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
                      onPressed: _handleConfirm,
                    ),
                  ),
                ],
              ),
            ),
            error: (e, _) => Center(
              child: CustomText(
                text: 'Error: $e',
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
