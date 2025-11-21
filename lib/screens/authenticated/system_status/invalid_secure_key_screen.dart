import '../../../../exports.dart';
import 'dart:io'; // Added for Platform detection

class InvalidSecureKeyScreen extends AuthenticatedScreen {
  InvalidSecureKeyScreen({super.key}) : super(pin_code_protected: false);

  static Future<InvalidSecureKeyScreen> create() async {
    final screen = InvalidSecureKeyScreen();
    return AuthenticatedScreen.create(screen);
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
                        'screen_invalid_secure_key.title',
                        fallback: 'Invalid Secure Key',
                      ),
                      type: CustomTextType.head,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    CustomText(
                      text: I18nService().t(
                        'screen_invalid_secure_key.description',
                        fallback: 'The secure key is invalid. Please insert your ID-Truster secure key from your backup.',
                      ),
                      type: CustomTextType.bread,
                    ),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                final saveButton = Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    key: const Key('invalid_secure_key_save_button'),
                    onPressed: () {},
                    text: I18nService().t(
                      'screen_invalid_secure_key.save_button',
                      fallback: 'Save',
                    ),
                    buttonType: CustomButtonType.secondary,
                  ),
                );

                return Platform.isAndroid ? SafeArea(top: false, child: saveButton) : saveButton;
              },
            ),
          ],
        ),
      ),
    );
  }
}
