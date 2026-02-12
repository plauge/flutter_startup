import '../../../../exports.dart';

final log = scopedLogger(LogCategory.gui);

Future<bool?> showUpdateSecurityKeyResetDialog(BuildContext context) async {
  log('_showResetConfirmDialog() - Showing reset confirmation dialog');

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: CustomText(
          text: I18nService().t(
            'screen_update_security_key.reset_dialog_title',
            fallback: 'Reset Security Key',
          ),
          type: CustomTextType.head,
        ),
        content: CustomText(
          text: I18nService().t(
            'screen_update_security_key.reset_dialog_content',
            fallback: 'This action will permanently delete all your contacts and reset your security key. This cannot be undone.\n\nAre you sure you want to continue?',
          ),
          type: CustomTextType.bread,
        ),
        actions: [
          CustomButton(
            key: const Key('reset_dialog_cancel_button'),
            text: I18nService().t(
              'screen_update_security_key.reset_dialog_cancel',
              fallback: 'Cancel',
            ),
            onPressed: () {
              log('_showResetConfirmDialog() - User cancelled reset');
              Navigator.of(context).pop(false);
            },
          ),
          const CustomText(
            text: '        ',
            type: CustomTextType.bread,
          ),
          CustomButton(
            key: const Key('reset_dialog_confirm_button'),
            buttonType: CustomButtonType.secondary,
            text: I18nService().t(
              'screen_update_security_key.reset_dialog_confirm',
              fallback: 'Reset',
            ),
            onPressed: () {
              log('_showResetConfirmDialog() - User confirmed reset');
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

// File created on 2026-02-10
