import '../../../../exports.dart';

class Level1CreateOrScanQrSelectorScreen extends AuthenticatedScreen {
  Level1CreateOrScanQrSelectorScreen({super.key});

  static Future<Level1CreateOrScanQrSelectorScreen> create() async {
    final screen = Level1CreateOrScanQrSelectorScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleCreateQRCode(BuildContext context) {
    context.go(RoutePaths.level1QrCodeCreator);
  }

  void _handleScanQRCode(BuildContext context) {
    context.go(RoutePaths.scanQrCode);
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
      appBar: const AuthenticatedAppBar(title: 'Meet in person', backRoutePath: RoutePaths.connect),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Meet in Person',
                  type: CustomTextType.head,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                Container(
                  padding: const EdgeInsets.fromLTRB(25, 13, 25, 13),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'This connection will be ',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Security Level 1',
                          textAlign: TextAlign.center,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                const CustomHelpText(
                  text: 'For at forbinde skal en af jer vælge Opret QR-kode, og den anden skal vælge Scan QR-kode.',
                  type: CustomTextType.label,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                // MenuItemCard(
                //   onTap: () => _handleCreateQRCode(context),
                //   icon: Icons.qr_code,
                //   title: 'Create QR Code',
                //   subtitle: 'Generate the QR code for your contact',
                // ),
                CustomCard(
                  icon: CardIcon.qrCode,
                  headerText: 'Opret QR-kode',
                  bodyText: 'Generate the QR code for your contact',
                  onPressed: () => _handleCreateQRCode(context),
                ),
                Gap(AppDimensionsTheme.getMedium(context)),

                CustomCard(
                  icon: CardIcon.camera,
                  headerText: 'Scan QR-kode',
                  bodyText: 'Scan the QR code your contact has generated',
                  onPressed: () => _handleScanQRCode(context),
                ),

                // Gap(AppDimensionsTheme.getLarge(context)),
                // CustomButton(
                //   text: 'Read About Using QR Codes',
                //   onPressed: () => _showQRCodeInfo(context),
                //   icon: Icons.info_outline,
                //   buttonType: CustomButtonType.secondary,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Created: 2024-12-20 16:30:00
