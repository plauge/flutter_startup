import '../../../exports.dart';
import '../../../services/i18n_service.dart';
import 'dart:io' show Platform;

class CheckEmailScreen extends UnauthenticatedScreen {
  final String email;

  const CheckEmailScreen({
    super.key,
    required this.email,
  });

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    print('🔍 CheckEmailScreen - Received email: "$email"');
    return AppTheme.getParentContainerStyle(context).applyToContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    CustomText(
                      text: I18nService().t('screen_login_check_email.login_check_email_header', fallback: 'Check your email'),
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    const SizedBox(height: 24),
                    CustomText(
                      text: I18nService().t(
                        'screen_login_check_email.login_check_email_description',
                        fallback: 'We have sent you a confirmation to $email. Click the link in the email to confirm your account.\n\nIf you don\'t see the email in your inbox within a few minutes, please check your Spam or Junk folder.',
                        variables: {'email': email},
                      ),
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.center,
                      selectable: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Platform.isAndroid
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CustomButton(
                      text: I18nService().t('screen_login_check_email.login_check_email_button', fallback: 'Back to login'),
                      onPressed: () => context.go(RoutePaths.login),
                      buttonType: CustomButtonType.secondary,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    text: I18nService().t('screen_login_check_email.login_check_email_button', fallback: 'Back to login'),
                    onPressed: () => context.go(RoutePaths.login),
                    buttonType: CustomButtonType.secondary,
                  ),
                ),
        ],
      ),
    );
  }
}
