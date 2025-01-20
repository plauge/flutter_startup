import '../../../../exports.dart';

class ConnectLevel1Screen extends AuthenticatedScreen {
  ConnectLevel1Screen({super.key});

  static Future<ConnectLevel1Screen> create() async {
    final screen = ConnectLevel1Screen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleCreateQRCode() {
    // TODO: Implement QR code generation
  }

  void _handleScanQRCode() {
    // TODO: Implement QR code scanning
  }

  void _showQRCodeInfo(BuildContext context) {
    // TODO: Implement QR code info modal
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
          title: 'Meet in person', backRoutePath: RoutePaths.connect),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Meet in Person',
                type: CustomTextType.head,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Container(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CustomText(
                      text: 'This connection will be ',
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.left,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const CustomText(
                        text: 'Security Level 1',
                        type: CustomTextType.cardDescription,
                        alignment: CustomTextAlignment.left,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              MenuItemCard(
                onTap: _handleCreateQRCode,
                icon: Icons.qr_code,
                title: 'Create QR Code',
                subtitle: 'Generate the QR code for your contact',
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              MenuItemCard(
                onTap: _handleScanQRCode,
                icon: Icons.camera_alt,
                title: 'Scan QR Code',
                subtitle: 'Scan the QR code your contact has generated',
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomButton(
                text: 'Read About Using QR Codes',
                onPressed: () => _showQRCodeInfo(context),
                icon: Icons.info_outline,
                buttonType: CustomButtonType.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
