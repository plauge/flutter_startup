import '../../../exports.dart';
import '../../../widgets/auth/magic_link_form.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/custom/custom_level_label.dart';
import '../../../services/i18n_service.dart';

class LoginScreen extends UnauthenticatedScreen {
  const LoginScreen({super.key});

  void _navigateToResetPassword(BuildContext context) {
    context.go(RoutePaths.resetPassword);
  }

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/id-truster-badge.svg',
                height: 150,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: const CustomText(
                text: 'ID-Truster',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: CustomText(
                text: I18nService().t('screen_login.login_header', fallback: 'Select access'),
                type: CustomTextType.cardHead,
                alignment: CustomTextAlignment.center,
              ),
            ),
            // const SizedBox(height: 24),
            // const CustomText(
            //   text: 'Your trusted tool for secure identity verification. With ID-TRUSTER, you can verify identities quickly, reliably, and with complete peace of mind.',
            //   type: CustomTextType.bread,
            //   alignment: CustomTextAlignment.center,
            // ),
            const SizedBox(height: 24),

// her fra
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  //Center(
                  Text(
                    I18nService().t('screen_login.login_description', fallback: 'Create account or login without password (recommended)'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF014459),
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  //),
                  const SizedBox(height: 10),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    key: const Key('login_main_button'),
                    onPressed: () => context.go(RoutePaths.loginMagicLink),
                    text: I18nService().t('screen_login.login_button', fallback: 'Login'),
                    buttonType: CustomButtonType.primary,
                  ),
                ],
              ),
            ),
// her til

            Gap(AppDimensionsTheme.getMedium(context)),
            Gap(AppDimensionsTheme.getMedium(context)),
            Row(
              children: [
                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensionsTheme.getSmall(context)),
                  child: CustomText(
                    text: I18nService().t('screen_login.login_or', fallback: 'or'),
                    type: CustomTextType.label,
                    alignment: CustomTextAlignment.center,
                  ),
                ),
                const Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),

            Gap(AppDimensionsTheme.getMedium(context)),
            Gap(AppDimensionsTheme.getMedium(context)),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                //color: const Color.fromARGB(255, 241, 241, 241),
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    I18nService().t('screen_login.login_description_with_password', fallback: 'Create user or login, where you need to use a password'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF014459),
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  //const SizedBox(height: 24),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    key: const Key('login_with_password_button'),
                    onPressed: () => context.go(RoutePaths.loginEmailPassword),
                    text: I18nService().t('screen_login.login_button_with_password', fallback: 'Login with email + password'),
                    buttonType: CustomButtonType.secondary,
                  ),
                ],
              ),
            ),
            // Gap(AppDimensionsTheme.getLarge(context)),
            // Center(
            //   child: CustomButton(
            //     onPressed: () => _navigateToResetPassword(context),
            //     text: I18nService().t('screen_login.login_forgot_password', fallback: 'Forgot password?'),
            //     buttonType: CustomButtonType.secondary,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
