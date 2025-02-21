import '../../../exports.dart';
import '../../../providers/qr_code_provider.dart';
import '../../../widgets/custom/custom_button.dart';
import '../../../widgets/custom/custom_text.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_dimensions_theme.dart';
import '../../../models/qr_code_read_response.dart';

class QrScreen extends AuthenticatedScreen {
  final String? qrCode;

  QrScreen({this.qrCode});

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
      appBar: const AuthenticatedAppBar(title: 'QR Kode'),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: _buildContent(context, ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    if (qrCode == null) {
      return Center(
        child: CustomText(
          text: 'QR kode mangler',
          type: CustomTextType.head,
        ),
      );
    }

    return ref.watch(readQrCodeProvider(qrCodeId: qrCode!)).when(
          data: (qrCodeResponses) {
            if (qrCodeResponses.isEmpty ||
                qrCodeResponses.first.statusCode != 200 ||
                qrCodeResponses.first.data.payload == null) {
              return _buildErrorView(context);
            }

            final payload = qrCodeResponses.first.data.payload!;
            return _buildQrInfoView(context, payload);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: CustomText(
              text: 'Der skete en fejl: $error',
              type: CustomTextType.bread,
            ),
          ),
        );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomText(
            text: 'Findes ikke',
            type: CustomTextType.head,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Prøv igen',
            onPressed: () => _handleRetry(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrInfoView(BuildContext context, QrCodePayload payload) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'QR Kode Information',
            type: CustomTextType.head,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomText(
            text: 'Type: ${payload.qrCodeType}',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Oprettet: ${payload.createdAt}',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Handling: ${payload.encryptedAction}',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: 'Note: ${payload.encryptedUserNote}',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomButton(
            text: 'Prøv igen',
            onPressed: () => _handleRetry(context),
          ),
        ],
      ),
    );
  }

  void _handleRetry(BuildContext context) {
    context.go(RoutePaths.home);
  }
}
