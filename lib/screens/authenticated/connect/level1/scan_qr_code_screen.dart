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
        debugPrint('QR Code scanned: ${scanData.code}');
        // Stop scanning after we get a valid code
        controller.dispose();
        // Navigate to confirm screen with the scanned ID
        context.go('${RoutePaths.confirmConnectionLevel1}?${scanData.code}');
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
      body: AppTheme.getParentContainerStyle(context, transparent: false).applyToContainer(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: 40,
                  bottom: 200,
                  left: 30,
                  right: 30,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
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
