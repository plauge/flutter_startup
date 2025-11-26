import '../../exports.dart';
import 'dart:io' show Platform;

class PasswordResetSuccessModal extends StatelessWidget {
  const PasswordResetSuccessModal({
    super.key,
  });

  static void show(BuildContext context) {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/password_reset_success_modal.dart][show] Showing password reset success modal');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            log('[widgets/modals/password_reset_success_modal.dart][show] Modal closed, navigating to login');
            Navigator.of(context).pop();
            context.go(RoutePaths.login);
          }
        },
        child: const PasswordResetSuccessModal(),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/password_reset_success_modal.dart][_navigateToLogin] Navigating to login');
    Navigator.of(context).pop();
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final modalContent = Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      I18nService().t(
                        'modal_password_reset_success.title',
                        fallback: 'Password Changed',
                      ),
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToLogin(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF014459),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomText(
                  text: I18nService().t(
                    'modal_password_reset_success.message',
                    fallback: 'Your password has been successfully changed. You can now log in with your new password.',
                  ),
                  type: CustomTextType.bread,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomButton(
                  key: const Key('password_reset_success_modal_button'),
                  onPressed: () => _navigateToLogin(context),
                  text: I18nService().t(
                    'modal_password_reset_success.button',
                    fallback: 'Go to Login',
                  ),
                  buttonType: CustomButtonType.primary,
                ),
              ],
            ),
          ),
        );

        return Platform.isAndroid ? SafeArea(top: false, child: modalContent) : modalContent;
      },
    );
  }
}

// File created: 2024-12-28 at 20:00

