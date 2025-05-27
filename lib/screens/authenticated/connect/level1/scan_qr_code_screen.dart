import '../../../../exports.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode

class ScanQRCodeScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  ScanQRCodeScreen({super.key});

  // Variable for test data, can be changed as needed
  String _testScanData = "invite=d359382f-d2fc-4827-9201-141196976988&key=M8oRgWfvLe0k%23nz(lAWJ5k9z4548xL_enqOxC%40m%5EN*o%26ja%239AC)%40qhJzH)zTj5Ec";

  static Future<ScanQRCodeScreen> create() async {
    final screen = ScanQRCodeScreen();
    return AuthenticatedScreen.create(screen);
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    AppLogger.logSeparator('_onQRViewCreated');
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        log('QR Code scanned: ${scanData.code}');
        // Stop scanning after we get a valid code
        controller.dispose();
        // Parse and navigate with the scanned data
        _parseAndNavigate(context, scanData.code!);
      }
    });
  }

  void _parseAndNavigate(BuildContext context, String qrData) {
    log('Parsing QR data: $qrData');

    try {
      // Parsing logic for QR code data
      final params = <String, String>{};
      final pairs = qrData.split('&');
      for (final pair in pairs) {
        final parts = pair.split('=');
        if (parts.length >= 2) {
          final key = Uri.decodeComponent(parts[0]);
          final value = Uri.decodeComponent(parts.sublist(1).join('='));
          params[key] = value;
        }
      }
      final queryParams = params;
      log('Parsed query params: $queryParams');

      final inviteId = queryParams['invite'];
      final keyValue = queryParams['key'];

      if (inviteId != null && keyValue != null) {
        final path = '${RoutePaths.confirmConnectionLevel1}?invite=${Uri.encodeComponent(inviteId)}&key=${Uri.encodeComponent(keyValue)}';
        log('Navigating to: $path');
        context.go(path);
      } else {
        log('Error: Missing invite or key in QR data. Parsed Params: $queryParams');
        CustomSnackBar.show(
          context: context,
          text: 'Invalid QR code format. Missing required parameters.',
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      log('Error parsing QR data: $e');
      CustomSnackBar.show(
        context: context,
        text: 'Error parsing QR code. Please try again.',
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _onTestButtonPressed(BuildContext context) {
    log('Test button pressed. Navigating with data: $_testScanData');
    _parseAndNavigate(context, _testScanData);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    AppLogger.logSeparator('Widget buildAuthenticatedWidget');
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
            if (kDebugMode)
              Padding(
                padding: EdgeInsets.only(bottom: AppDimensionsTheme.getLarge(context)),
                child: CustomButton(
                  text: 'Test Navigation',
                  onPressed: () => _onTestButtonPressed(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
