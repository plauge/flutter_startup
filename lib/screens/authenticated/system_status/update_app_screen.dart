import '../../../../exports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UpdateAppScreen extends AuthenticatedScreen {
  UpdateAppScreen({super.key}) : super(pin_code_protected: false);

  static Future<UpdateAppScreen> create() async {
    final screen = UpdateAppScreen();
    return AuthenticatedScreen.create(screen);
  }

  Future<void> _openAppStore() async {
    final String storeUrl;
    if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/app/id6742175686';
    } else if (Platform.isAndroid) {
      storeUrl = 'https://play.google.com/store/apps/details?id=eu.idtruster.app&hl=en-US';
    } else {
      throw Exception('Unsupported platform');
    }
    final Uri url = Uri.parse(storeUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: I18nService().t(
                        'screen_update_app.title',
                        fallback: 'App Update Required',
                      ),
                      type: CustomTextType.head,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    CustomText(
                      text: I18nService().t(
                        'screen_update_app.description',
                        fallback: 'A new version of the app is available. Please update to continue using the app.',
                      ),
                      type: CustomTextType.bread,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomButton(
                onPressed: _openAppStore,
                text: I18nService().t(
                  'screen_update_app.update_button',
                  fallback: 'Update ID-Truster',
                ),
                buttonType: CustomButtonType.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
