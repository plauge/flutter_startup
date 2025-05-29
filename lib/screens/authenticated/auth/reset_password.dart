import '../../../exports.dart';
import '../../../widgets/auth/reset_password_form.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResetPasswordScreen extends AuthenticatedScreen {
  ResetPasswordScreen({super.key});

  static Future<ResetPasswordScreen> create() async {
    AppLogger.logSeparator('ResetPasswordScreen.create');
    final screen = ResetPasswordScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(BuildContext context, WidgetRef ref, AuthenticatedState auth) {
    AppLogger.logSeparator('ResetPasswordScreen');
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Reset password',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/id-truster-badge.svg',
                height: 150,
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const Center(
              child: CustomText(
                text: 'Reset password',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            Gap(AppDimensionsTheme.getMedium(context)),
            const Center(
              child: CustomText(
                text: 'Enter your new password and confirm it to update your account',
                type: CustomTextType.bread,
                alignment: CustomTextAlignment.center,
              ),
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: ResetPasswordForm(),
            ),
          ],
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 18:45
