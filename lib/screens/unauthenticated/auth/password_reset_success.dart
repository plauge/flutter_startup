import '../../../exports.dart';
import '../../../services/i18n_service.dart';
import 'dart:io' show Platform;
import 'package:flutter_svg/flutter_svg.dart';

class PasswordResetSuccessScreen extends UnauthenticatedScreen {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget buildUnauthenticatedWidget(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
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
                      Gap(AppDimensionsTheme.getLarge(context)),
                      SvgPicture.asset(
                        'assets/images/id-truster-badge.svg',
                        height: 150,
                      ),
                      Gap(AppDimensionsTheme.getLarge(context)),
                      CustomText(
                        text: I18nService().t(
                          'screen_password_reset_success.title',
                          fallback: 'Password Changed',
                        ),
                        type: CustomTextType.head,
                        alignment: CustomTextAlignment.center,
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      CustomText(
                        text: I18nService().t(
                          'screen_password_reset_success.message',
                          fallback: 'Your password has been successfully changed. You can now log in with your new password.',
                        ),
                        type: CustomTextType.bread,
                        alignment: CustomTextAlignment.center,
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
                        key: const Key('password_reset_success_go_to_login_button'),
                        text: I18nService().t(
                          'screen_password_reset_success.button',
                          fallback: 'Go to Login',
                        ),
                        onPressed: () => context.go(RoutePaths.login),
                        buttonType: CustomButtonType.primary,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CustomButton(
                      key: const Key('password_reset_success_go_to_login_button'),
                      text: I18nService().t(
                        'screen_password_reset_success.button',
                        fallback: 'Go to Login',
                      ),
                      onPressed: () => context.go(RoutePaths.login),
                      buttonType: CustomButtonType.primary,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 21:00

