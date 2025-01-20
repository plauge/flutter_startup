import '../../../../exports.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQRCodeScreen extends AuthenticatedScreen {
  ScanQRCodeScreen({super.key});

  static Future<ScanQRCodeScreen> create() async {
    final screen = ScanQRCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const CustomText(
              text: 'QR Code Scanned',
              type: CustomTextType.head,
            ),
            content: CustomText(
              text: 'Scanned code: ${scanData.code}',
              type: CustomTextType.bread,
            ),
            actions: [
              CustomButton(
                text: 'OK',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Scan QR Code',
        backRoutePath: RoutePaths.connectLevel1,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryColor(context),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: (controller) =>
                        _onQRViewCreated(controller, context),
                  ),
                ),
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text: 'Hold your camera up to a QR code to scan it',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
          ],
        ),
      ),
    );
  }
}
