import '../../../../exports.dart';

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
                    const CustomText(
                      text: 'Invalid Secure Key',
                      type: CustomTextType.head,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    const CustomText(
                      text: 'The secure key is invalid. Please insert your ID-Truster secure key from your backup.',
                      type: CustomTextType.bread,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CustomButton(
                  key: const Key('invalid_secure_key_save_button'),
                  onPressed: () {},
                  text: 'Save',
                  buttonType: CustomButtonType.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
