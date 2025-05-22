import '../../../../exports.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAppScreen extends AuthenticatedScreen {
  UpdateAppScreen({super.key}) : super(pin_code_protected: false);

  static Future<UpdateAppScreen> create() async {
    final screen = UpdateAppScreen();
    return AuthenticatedScreen.create(screen);
  }

  Future<void> _openAppStore() async {
    final Uri url = Uri.parse('https://apps.apple.com/app/id6742175686');
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
                    const CustomText(
                      text: 'App Update Required',
                      type: CustomTextType.head,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    const CustomText(
                      text:
                          'A new version of the app is available. Please update to continue using the app.',
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
                text: 'Update ID-Truster',
                buttonType: CustomButtonType.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
