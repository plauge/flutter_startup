import '../../exports.dart';
import 'dart:io' show Platform;

class PasswordResetErrorModal extends StatelessWidget {
  const PasswordResetErrorModal({
    super.key,
  });

  static void show(BuildContext context) {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/password_reset_error_modal.dart][show] Showing password reset error modal');

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
            log('[widgets/modals/password_reset_error_modal.dart][show] Modal closed, navigating to forgot password');
            Navigator.of(context).pop();
            context.go(RoutePaths.forgotPassword);
          }
        },
        child: const PasswordResetErrorModal(),
      ),
    );
  }

  void _navigateToForgotPassword(BuildContext context) {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/password_reset_error_modal.dart][_navigateToForgotPassword] Navigating to forgot password');
    Navigator.of(context).pop();
    context.go(RoutePaths.forgotPassword);
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
                        'modal_password_reset_error.title',
                        fallback: 'PIN Code Incorrect',
                      ),
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToForgotPassword(context),
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
                    'modal_password_reset_error.message',
                    fallback: 'The PIN code you entered was incorrect or has expired. Please request a new PIN code.',
                  ),
                  type: CustomTextType.bread,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomButton(
                  key: const Key('password_reset_error_modal_button'),
                  onPressed: () => _navigateToForgotPassword(context),
                  text: I18nService().t(
                    'modal_password_reset_error.button',
                    fallback: 'Request New PIN Code',
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

