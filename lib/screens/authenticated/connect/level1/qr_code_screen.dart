import '../../../../exports.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Create new connection',
        backRoutePath: RoutePaths.connectLevel1,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/placeholder.png'),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                const CustomText(
                  text: 'Name Nameson',
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
                const CustomText(
                  text: 'Company Ltd',
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Container(
                  padding:
                      EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
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
                      'The person you want to connect with simply needs to scan this QR code in their own EnigMe app. After scanning the QR code, please close this window.',
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomButton(
                text: 'Confirm',
                onPressed: _handleConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
