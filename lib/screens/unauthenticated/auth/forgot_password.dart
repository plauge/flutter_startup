import '../../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/i18n_service.dart';

class ForgotPasswordScreen extends UnauthenticatedScreen {
  const ForgotPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_login_forgot_password.forgot_password_header', fallback: 'Forgot password'),
        backRoutePath: RoutePaths.login,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: Column(
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/images/id-truster-badge.svg',
                  height: 120,
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Center(
                child: CustomText(
                  text: I18nService().t('screen_login_forgot_password.forgot_password_header', fallback: 'Forgot password'),
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              Center(
                child: CustomText(
                  text: I18nService().t('screen_login_forgot_password.forgot_password_description', fallback: 'Enter your email address and we\'ll send you a email to reset your password'),
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ForgotPasswordForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 17:15
