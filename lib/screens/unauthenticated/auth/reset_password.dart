import '../../../exports.dart';
import '../../../services/i18n_service.dart';

class ResetPasswordScreen extends UnauthenticatedScreen {
  const ResetPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    // Hent query parameters fra URL'en
    final queryParams = GoRouterState.of(context).queryParameters;
    final token = queryParams['token'];
    final code = queryParams['code'];
    final email = queryParams['email'];

    // Bestem hvilken widget der skal bruges baseret på query parameters
    final bool usePinFlow = email != null && email.isNotEmpty && token == null && code == null;
    final String backRoutePath = usePinFlow ? RoutePaths.forgotPassword : '/home';

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_reset_password.reset_password_header', fallback: 'Reset password'),
        backRoutePath: backRoutePath,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (usePinFlow)
                  ResetPasswordFormPin(
                    email: email,
                  )
                else
                  ResetPasswordForm(
                    token: token,
                    email: email,
                  ),
                Gap(AppDimensionsTheme.of(context).large),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Created: 2024-12-19 15:30:00
