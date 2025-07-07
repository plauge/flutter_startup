import '../../../../exports.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode

class Level1QrCodeScannerScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
  Level1QrCodeScannerScreen({super.key});

  // Variable for test data, can be changed as needed
  final String absoluteURLForTest = 'idtruster://idtruster.eu/invitation/level1?';
  final String testScanData = "invite=026e724e-6d7b-4b00-bd82-7986004cee21&key=lClDeBDbtsG%5EK%2BSuej%5E0%26Kmk8ZY1ya)IFhDqPS%26pf%25a7jetg%2B_v9D%5Er*4VJplkWW";

  static Future<Level1QrCodeScannerScreen> create() async {
    final screen = Level1QrCodeScannerScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _onDetect(BarcodeCapture capture, BuildContext context, WidgetRef ref, MobileScannerController controller) {
    AppLogger.logSeparator('_onDetect');
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      log('QR Code scanned: $code');

      // Stop scanning after we get a valid code
      controller.dispose();

      // Parse and navigate with the scanned data
      final correctedTestScanData = Uri.encodeFull(code);
      _parseAndNavigate(context, correctedTestScanData);
    }
  }

  void _parseAndNavigate(BuildContext context, String qrData) {
    log('Raw QR data: $qrData');
    log('Attempting to parse QR data...');

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
          log('Decoded pair: $key = $value');
        } else {
          log('Invalid pair encountered: $pair');
        }
      }
      final queryParams = params;
      log('Parsed query params: $queryParams');

      final inviteId = queryParams['invite'];
      final keyValue = queryParams['key'];

      if (inviteId != null && keyValue != null) {
        final path = '${RoutePaths.level1ConfirmConnection}?invite=${Uri.encodeComponent(inviteId)}&key=${Uri.encodeComponent(keyValue)}';
        log('Navigating to: $path');
        context.go(path);
      } else {
        log('Error: Missing invite or key in QR data. Parsed Params: $queryParams');
        CustomSnackBar.show(
          context: context,
          text: I18nService().t('screen_contacts_connect_qr_code_scanner.qr_code_scanner_invalid_qr_code_format', fallback: 'Invalid QR code format. Missing required parameters.'),
          type: CustomTextType.button,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      log('Error parsing QR data: $e');
      CustomSnackBar.show(
        context: context,
        text: I18nService().t('screen_contacts_connect_qr_code_scanner.qr_code_scanner_error_parsing_qr_code', fallback: 'Error parsing QR code. Please try again.'),
        type: CustomTextType.button,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _onTestButtonPressed(BuildContext context) {
    // Correct the URL encoding of testScanData before using it
    final correctedTestScanData = Uri.encodeFull(testScanData);
    log('Test button pressed. Navigating with data: $correctedTestScanData');
    _parseAndNavigate(context, correctedTestScanData);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState auth,
  ) {
    AppLogger.logSeparator('Widget buildAuthenticatedWidget');
    final controller = MobileScannerController();

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts_connect_qr_code_scanner.qr_code_scanner_header', fallback: 'Scan QR Code'),
        backRoutePath: RoutePaths.level1CreateOrScanQr,
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
              CustomText(
                text: I18nService().t('screen_contacts_connect_qr_code_scanner.qr_code_scanner_body', fallback: 'Hold your camera up to a QR code to scan it'),
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
      ),
    );
  }
}

// Created: 2024-12-20 17:00:00
