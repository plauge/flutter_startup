import '../../../exports.dart';
import '../../../providers/qr_code_provider.dart';
import '../../../widgets/custom/custom_button.dart';
import '../../../widgets/custom/custom_text.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_dimensions_theme.dart';
import '../../../models/qr_code_read_response.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class QrScreen extends AuthenticatedScreen with WidgetsBindingObserver {
  static final log = scopedLogger(LogCategory.gui);

  final String? qrCode;
  String? _qrType;
  String? _decryptKey;
  bool _isUrlLaunched = false; // Track if URL was launched

  QrScreen({this.qrCode}) : super(pin_code_protected: false);

  static Future<QrScreen> create({String? qrCode}) async {
    final screen = QrScreen(qrCode: qrCode);
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Add observer for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'QR Code',
        backRoutePath: '/home',
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: _buildContent(context, ref),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    log('QrScreen: App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        if (_isUrlLaunched) {
          log('QrScreen: App resumed after URL launch');
          _isUrlLaunched = false;
          // Give the app time to stabilize after returning
          Future.delayed(const Duration(milliseconds: 200), () {
            if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
              log('QrScreen: App fully resumed and stable');
            }
          });
        }
        break;
      case AppLifecycleState.paused:
        log('QrScreen: App paused');
        break;
      case AppLifecycleState.inactive:
        log('QrScreen: App inactive');
        break;
      case AppLifecycleState.detached:
        log('QrScreen: App detached');
        _cleanup();
        break;
      case AppLifecycleState.hidden:
        log('QrScreen: App hidden');
        break;
    }
  }

  void _cleanup() {
    log('QrScreen: Cleaning up resources');
    WidgetsBinding.instance.removeObserver(this);
    _isUrlLaunched = false;
  }

  String? _parseQrCode(String rawQrCode) {
    if (!rawQrCode.startsWith('idtruster,')) return null;
    final parts = rawQrCode.split(',');
    if (parts.length != 4) return null;
    _qrType = parts[1];
    _decryptKey = parts[3];
    return parts[2];
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}/';
    } catch (e) {
      return url; // Return original if parsing fails
    }
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    if (qrCode == null) {
      return Center(
        child: CustomText(
          text: 'QR code missing',
          type: CustomTextType.head,
        ),
      );
    }

    final bool isIdTruster = qrCode!.startsWith('idtruster,');
    String? qrCodeId;
    String? qrPath;

    if (isIdTruster) {
      qrCodeId = _parseQrCode(qrCode!);
    } else {
      qrPath = qrCode;
    }

    return ref.watch(readQrCodeProvider(qrCodeId: qrCodeId, qrPath: qrPath)).when(
          data: (qrCodeResponses) {
            if (qrCodeResponses.isEmpty || qrCodeResponses.first.statusCode != 200 || qrCodeResponses.first.data.payload == null) {
              return _buildErrorView(context);
            }

            final payload = qrCodeResponses.first.data.payload!;
            return _buildQrInfoView(context, payload);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorView(context),
        );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomText(
            text: 'Invalid QR code',
            type: CustomTextType.head,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Try again',
            onPressed: () => _handleRetry(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrInfoView(BuildContext context, QrCodePayload payload) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(payload.createdAt.toLocal());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'QR Info',
            type: CustomTextType.head,
          ),
          // Gap(AppDimensionsTheme.getLarge(context)),
          // CustomText(
          //   text: 'Type: ${payload.qrCodeType}',
          //   type: CustomTextType.bread,
          // ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Link to: ${_extractDomain(payload.encryptedAction)}',
            type: CustomTextType.bread,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Note: ${payload.encryptedUserNote}',
            type: CustomTextType.bread,
          ),

          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Company: ${payload.customerName ?? 'Missing'}',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Created: $formattedDate',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomButton(
            text: 'Open link',
            onPressed: () => _handleOpenUrl(payload.encryptedAction),
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            text: 'Try again',
            onPressed: () => _handleRetry(context),
            buttonType: CustomButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenUrl(String url) async {
    try {
      log('QrScreen._handleOpenUrl: Attempting to open URL: $url');

      // Validate URL first
      if (url.isEmpty) {
        log('QrScreen._handleOpenUrl: Empty URL provided');
        return;
      }

      final uri = Uri.parse(url);
      log('QrScreen._handleOpenUrl: Parsed URI: ${uri.toString()}');

      // Check if URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        log('QrScreen._handleOpenUrl: Cannot launch URL: $url');
        return;
      }

      log('QrScreen._handleOpenUrl: Launching URL in external application');

      // Set flag before launching
      _isUrlLaunched = true;

      // Launch with proper mode and handle potential failures
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (success) {
        log('QrScreen._handleOpenUrl: Successfully launched URL');
        // URL launch was successful, tracking is already set
      } else {
        log('QrScreen._handleOpenUrl: Failed to launch URL');
        _isUrlLaunched = false; // Reset flag if launch failed
      }
    } on FormatException catch (e, stackTrace) {
      log('QrScreen._handleOpenUrl: Invalid URL format: $e');
      log('QrScreen._handleOpenUrl: Stack trace: $stackTrace');
      _isUrlLaunched = false;
    } on PlatformException catch (e, stackTrace) {
      log('QrScreen._handleOpenUrl: Platform error: $e');
      log('QrScreen._handleOpenUrl: Stack trace: $stackTrace');
      _isUrlLaunched = false;
    } catch (e, stackTrace) {
      log('QrScreen._handleOpenUrl: Unexpected error opening URL: $e');
      log('QrScreen._handleOpenUrl: Stack trace: $stackTrace');
      _isUrlLaunched = false;
    }
  }

  void _handleRetry(BuildContext context) {
    log('QrScreen._handleRetry: Navigating back to home');
    _cleanup(); // Clean up before navigation
    context.go(RoutePaths.scanQr);
  }
}
