import '../../../../../exports.dart';
import '../../../../../services/i18n_service.dart';

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
      appBar: AuthenticatedAppBar(title: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_header', fallback: 'Meet in person'), backRoutePath: RoutePaths.connect),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomText(
                  text: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_header', fallback: 'Meet in Person'),
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                // Container(
                //   padding: const EdgeInsets.fromLTRB(25, 13, 25, 13),
                //   decoration: BoxDecoration(
                //     color: Colors.black,
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_body', fallback: 'This connection will be '),
                //         textScaler: TextScaler.noScaling,
                //         style: TextStyle(
                //           color: const Color(0xFFFFFFFF),
                //           fontFamily: 'Poppins',
                //           fontSize: 14,
                //           fontWeight: FontWeight.w400,
                //           height: 1.0,
                //         ),
                //       ),
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 8,
                //           vertical: 9,
                //         ),
                //         decoration: BoxDecoration(
                //           color: Colors.green,
                //           borderRadius: BorderRadius.circular(6),
                //         ),
                //         child: Text(
                //           I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_security_level', fallback: 'Security Level 1'),
                //           textAlign: TextAlign.center,
                //           textScaler: TextScaler.noScaling,
                //           style: TextStyle(
                //             color: Color(0xFFFFFFFF),
                //             fontFamily: 'Poppins',
                //             fontSize: 12,
                //             fontWeight: FontWeight.w700,
                //             height: 1.15,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Gap(AppDimensionsTheme.getLarge(context)),
                CustomHelpText(
                  text: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_help_text', fallback: 'To connect, one of you must choose Create QR Code, and the other must choose Scan QR Code.'),
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
                  headerText: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_create_qr_code', fallback: 'Create QR Code'),
                  bodyText: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_create_qr_code_body', fallback: 'Generate the QR code for your contact'),
                  onPressed: () => _handleCreateQRCode(context),
                ),
                Gap(AppDimensionsTheme.getMedium(context)),

                CustomCard(
                  icon: CardIcon.camera,
                  headerText: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_scan_qr_code', fallback: 'Scan QR Code'),
                  bodyText: I18nService().t('screen_contacts_connect_meet_in_person.meet_in_person_scan_qr_code_body', fallback: 'Scan the QR code your contact has generated'),
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
