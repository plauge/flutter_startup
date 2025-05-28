import '../../../exports.dart';
import '../../../providers/qr_code_provider.dart';
import '../../../widgets/custom/custom_button.dart';
import '../../../widgets/custom/custom_text.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_dimensions_theme.dart';
import '../../../models/qr_code_read_response.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class QrScreen extends AuthenticatedScreen {
  final String? qrCode;
  String? _qrType;
  String? _decryptKey;

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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleRetry(BuildContext context) {
    context.go(RoutePaths.home);
  }
}
