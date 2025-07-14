import '../../exports.dart';
import '../../services/i18n_service.dart';

class PhoneNumbersScreen extends AuthenticatedScreen {
  PhoneNumbersScreen({super.key}) : super(pin_code_protected: false);

  static Future<PhoneNumbersScreen> create() async {
    final screen = PhoneNumbersScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_phone_numbers.title', fallback: 'Phone Numbers'),
        backRoutePath: '/settings',
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomText(
                  text: I18nService().t('screen_phone_numbers.description', fallback: 'Manage your phone numbers and configure how you receive verification codes.'),
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Created: 2024-12-30 09:00:00
