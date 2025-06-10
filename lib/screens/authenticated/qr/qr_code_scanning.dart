import '../../../exports.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';

class QrCodeScanningScreen extends AuthenticatedScreen {
  QrCodeScanningScreen({super.key}) : super(pin_code_protected: false);

  static Future<QrCodeScanningScreen> create() async {
    final screen = QrCodeScanningScreen();
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
        // Navigate to QR screen with the scanned code
        context.go('${RoutePaths.qrScreen}?qr_code=${scanData.code}');
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
        backRoutePath: RoutePaths.home,
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
            GestureDetector(
              onTap: () => _simulateScan(context),
              child: const CustomText(
                text: 'Hold your camera up to a QR code to scan it',
                type: CustomTextType.bread,
                alignment: CustomTextAlignment.center,
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
          ],
        ),
      ),
    );
  }

  void _simulateScan(BuildContext context) {
    // Kun tillad simulering i debug mode
    if (!kDebugMode) {
      debugPrint('_simulateScan called but app is not in debug mode');
      return;
    }

    // Simuler scanning af en specifik QR-kode
    final String simulatedQrCode = 'idtruster,url,3ede200f-7df2-447f-8346-1560b3ae2e8f,test';
    debugPrint('Simulating QR Code scan: $simulatedQrCode');

    // Dispose controller hvis den er aktiv
    controller?.dispose();

    // Naviger til QR-skærmen med den simulerede kode
    context.go('${RoutePaths.qrScreen}?qr_code=$simulatedQrCode');
  }
}
