import '../../../exports.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart';

class QrCodeScanningScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  QrCodeScanningScreen({super.key}) : super(pin_code_protected: false);

  static Future<QrCodeScanningScreen> create() async {
    final screen = QrCodeScanningScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _onDetect(BarcodeCapture capture, BuildContext context, WidgetRef ref, MobileScannerController controller) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      log('QR Code scanned: $code');

      // Stop scanning after we get a valid code
      controller.dispose();

      // Navigate to QR screen with the scanned code
      context.go('${RoutePaths.qrCodeResult}?qr_code=${Uri.encodeComponent(code)}');
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    // Create controller - it will be disposed automatically when widget is disposed
    final controller = MobileScannerController();

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_qr_code_scanning.qr_code_scanning_header', fallback: 'Scan QR Code'),
        backRoutePath: RoutePaths.home,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context, transparent: false).applyToContainer(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
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
                    child: MobileScanner(
                      controller: controller,
                      onDetect: (capture) => _onDetect(capture, context, ref, controller),
                    ),
                  ),
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              GestureDetector(
                onTap: () => _simulateScan(context),
                child: CustomText(
                  text: I18nService().t('screen_qr_code_scanning.qr_code_scanning_body', fallback: 'Hold your camera up to a QR code to scan it'),
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateScan(BuildContext context) {
    // Kun tillad simulering i debug mode
    if (!kDebugMode) {
      log('_simulateScan called but app is not in debug mode');
      return;
    }

    // Simuler scanning af en specifik QR-kode
    const String simulatedQrCode = 'idtruster,url,3ede200f-7df2-447f-8346-1560b3ae2e8f,test';
    log('Simulating QR Code scan: $simulatedQrCode');

    // Naviger til QR-skærmen med den simulerede kode
    context.go('${RoutePaths.qrCodeResult}?qr_code=${Uri.encodeComponent(simulatedQrCode)}');
  }
}

// Created: 2024-12-20 17:00:00
