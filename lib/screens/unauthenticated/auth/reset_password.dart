import '../../../exports.dart';

class ResetPasswordScreen extends UnauthenticatedScreen {
  const ResetPasswordScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    // Hent query parameters fra URL'en
    final queryParams = GoRouterState.of(context).queryParameters;
    final token = queryParams['token'];
    final code = queryParams['code'];
    final type = queryParams['type'];

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Reset password',
        backRoutePath: '/home',
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
                ResetPasswordForm(
                  token: token,
                  email: queryParams['email'],
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
