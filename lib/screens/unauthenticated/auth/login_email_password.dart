import '../../../exports.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/i18n_service.dart';

class LoginEmailPasswordScreen extends UnauthenticatedScreen {
  const LoginEmailPasswordScreen({super.key});

  void _onForgotPasswordPressed(BuildContext context) {
    context.go(RoutePaths.forgotPassword);
  }

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_login_email_and_password.login_email_and_password_header', fallback: 'Email & Password Login'),
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: DefaultTabController(
            length: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/id-truster-badge.svg',
                      height: 150,
                    ),
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  Center(
                    child: CustomText(
                      text: I18nService().t('screen_login_email_and_password.login_email_and_password_header', fallback: 'Email & Password Login'),
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  LoginCreateAccountTabs(
                    onForgotPassword: () => _onForgotPasswordPressed(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 15:30
