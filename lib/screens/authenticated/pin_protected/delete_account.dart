import '../../../exports.dart';
import '../../../providers/auth_delete_provider.dart';

class DeleteAccountScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

  DeleteAccountScreen({super.key}) : super(pin_code_protected: true, face_id_protected: true);

  static Future<DeleteAccountScreen> create() async {
    final screen = DeleteAccountScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackDeleteAccountEvent(WidgetRef ref, String eventType, String action) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('delete_account_event', {
      'event_type': eventType,
      'action': action,
      'screen': 'delete_account',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    _trackDeleteAccountEvent(ref, 'show_confirmation', 'delete_account_dialog_shown');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t('screen_delete_account.delete_account_confirmation_title', fallback: 'Confirm Account Deletion'),
            type: CustomTextType.bread,
          ),
          content: CustomText(
            text: I18nService().t('screen_delete_account.delete_account_confirmation_description', fallback: 'Are you sure you want to delete your account? This action cannot be undone.'),
            type: CustomTextType.bread,
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  key: const Key('delete_account_confirmation_cancel_button'),
                  text: I18nService().t('screen_delete_account.delete_account_confirmation_cancel_button', fallback: 'Cancel'),
                  onPressed: () => _handleCancelDelete(context, ref),
                  buttonType: CustomButtonType.primary,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomButton(
                  key: const Key('delete_account_confirmation_confirm_button'),
                  text: I18nService().t('screen_delete_account.delete_account_confirmation_button', fallback: 'Delete Account'),
                  onPressed: () => _handleConfirmDelete(context, ref),
                  buttonType: CustomButtonType.secondary,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleCancelDelete(BuildContext context, WidgetRef ref) {
    _trackDeleteAccountEvent(ref, 'cancel', 'delete_account_cancelled');
    Navigator.of(context).pop();
  }

  void _handleConfirmDelete(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    _trackDeleteAccountEvent(ref, 'confirm', 'delete_account_confirmed');
    
    try {
      final userEmail = ref.read(authProvider)?.email;
      final authDelete = ref.read(authDeleteProvider.notifier);
      final success = await authDelete.deleteUser();

      if (success) {
        _trackDeleteAccountEvent(ref, 'delete_success', 'account_deleted_successfully');
        if (userEmail != null && userEmail.isNotEmpty) {
          await ref.read(storageProvider.notifier).deleteUserStorageDataByEmail(userEmail);
          log('[screens/authenticated/pin_protected/delete_account.dart][_handleConfirmDelete] Removed local secure storage data for: $userEmail');
        }
        await ref.read(authProvider.notifier).signOut();
        
        // Use addPostFrameCallback to ensure navigation happens even if context was unmounted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final router = GoRouter.maybeOf(context);
            if (router != null) {
              router.go(RoutePaths.login);
            } else if (context.mounted) {
              context.go(RoutePaths.login);
            }
          } catch (e) {
            if (context.mounted) {
              context.go(RoutePaths.login);
            }
          }
        });
      } else {
        _trackDeleteAccountEvent(ref, 'delete_error', 'account_deletion_failed');
        if (context.mounted) {
          _showAlert(context, I18nService().t('screen_delete_account.delete_account_error_message', fallback: 'An error occurred while deleting your account'));
        }
      }
    } catch (e) {
      log('[screens/authenticated/pin_protected/delete_account.dart][_handleConfirmDelete] Exception during delete: $e');
      _trackDeleteAccountEvent(ref, 'delete_error', 'account_deletion_exception');
      if (context.mounted) {
        _showAlert(context, I18nService().t('screen_delete_account.delete_account_error_message', fallback: 'An error occurred while deleting your account'));
      }
    }
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            I18nService().t('screen_delete_account.delete_account_alert_title', fallback: 'Alert'),
            style: AppTheme.getBodyLarge(context),
          ),
          content: Text(
            message,
            style: AppTheme.getBodyMedium(context),
          ),
          actions: [
            TextButton(
              key: const Key('delete_account_alert_ok_button'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                I18nService().t('screen_delete_account.delete_account_alert_button', fallback: 'OK'),
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_delete_account.delete_account_header', fallback: 'Delete My Account'),
        backRoutePath: RoutePaths.settings,
        showSettings: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header text

                CustomText(
                  text: I18nService().t('screen_delete_account.delete_account_header', fallback: 'Delete My Account'),
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomText(
                  text: I18nService().t(
                    'screen_delete_account.delete_account_description',
                    fallback: 'Deleting your account will permanently remove all your data, including your profile, contacts, and all associated information. This action cannot be undone and your data cannot be recovered.',
                  ),
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomButton(
                  key: const Key('delete_account_confirm_button'),
                  text: I18nService().t('screen_delete_account.delete_account_button', fallback: 'Delete My Account'),
                  onPressed: () => _handleDeleteAccount(context, ref),
                  buttonType: CustomButtonType.alert,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Created: 2024-12-19
