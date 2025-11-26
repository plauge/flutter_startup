import '../../../exports.dart';
import '../../../services/i18n_service.dart';
import 'dart:io' show Platform;

class PasswordResetErrorScreen extends UnauthenticatedScreen {
  const PasswordResetErrorScreen({super.key});

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
                      CustomText(
                        text: I18nService().t(
                          'screen_password_reset_error.title',
                          fallback: 'PIN Code Incorrect',
                        ),
                        type: CustomTextType.head,
                        alignment: CustomTextAlignment.center,
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      CustomText(
                        text: I18nService().t(
                          'screen_password_reset_error.message',
                          fallback: 'The PIN code you entered was incorrect or has expired. Please request a new PIN code.',
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
                        key: const Key('password_reset_error_request_new_button'),
                        text: I18nService().t(
                          'screen_password_reset_error.button',
                          fallback: 'Request New PIN Code',
                        ),
                        onPressed: () => context.go(RoutePaths.forgotPassword),
                        buttonType: CustomButtonType.alert,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CustomButton(
                      key: const Key('password_reset_error_request_new_button'),
                      text: I18nService().t(
                        'screen_password_reset_error.button',
                        fallback: 'Request New PIN Code',
                      ),
                      onPressed: () => context.go(RoutePaths.forgotPassword),
                      buttonType: CustomButtonType.alert,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// File created: 2024-12-28 at 21:00

