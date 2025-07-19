import '../../exports.dart';
import '../../providers/security_provider.dart';
import '../../providers/auth_delete_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends AuthenticatedScreen {
  SettingsScreen({super.key}) : super(pin_code_protected: false);

  static Future<SettingsScreen> create() async {
    final screen = SettingsScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _trackSettingsCardPressed(WidgetRef ref, String cardType, String destination) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('settings_card_pressed', {
      'card_type': cardType,
      'destination': destination,
      'screen': 'settings',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _trackSettingsButtonPressed(WidgetRef ref, String buttonType, String action) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('settings_button_pressed', {
      'button_type': buttonType,
      'action': action,
      'screen': 'settings',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _handleProfileEdit(BuildContext context, WidgetRef ref) {
    _trackSettingsCardPressed(ref, 'my_profile', 'profile_edit');
    context.go(RoutePaths.profileEdit);
  }

  void _handleSupport(WidgetRef ref) async {
    _trackSettingsCardPressed(ref, 'support_feedback', 'external_support');
    final Uri url = Uri.parse('https://idtruster.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('SettingsScreen: Could not launch $url');
    }
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    _trackSettingsCardPressed(ref, 'delete_account', 'delete_account_dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t('screen_settings.delete_account_confirmation_title', fallback: 'Confirm Account Deletion'),
            type: CustomTextType.bread,
          ),
          content: CustomText(
            text: I18nService().t('screen_settings.delete_account_confirmation_description', fallback: 'Are you sure you want to delete your account? This action cannot be undone.'),
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              text: I18nService().t('screen_settings.delete_account_confirmation_cancel_button', fallback: 'Cancel'),
              onPressed: () => _handleCancelDelete(context, ref),
              buttonType: CustomButtonType.secondary,
            ),
            CustomButton(
              text: I18nService().t('screen_settings.delete_account_confirmation_button', fallback: 'Delete Account'),
              onPressed: () => _handleConfirmDelete(context, ref),
              buttonType: CustomButtonType.alert,
            ),
          ],
        );
      },
    );
  }

  void _handleCancelDelete(BuildContext context, WidgetRef ref) {
    _trackSettingsButtonPressed(ref, 'cancel', 'delete_account_cancelled');
    Navigator.of(context).pop();
  }

  void _handleConfirmDelete(BuildContext context, WidgetRef ref) async {
    _trackSettingsButtonPressed(ref, 'confirm', 'delete_account_confirmed');
    final authDelete = ref.read(authDeleteProvider.notifier);
    final success = await authDelete.deleteUser();

    if (!context.mounted) return;

    if (success) {
      _trackSettingsButtonPressed(ref, 'delete_success', 'account_deleted_successfully');
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        context.go(RoutePaths.login);
      }
    } else {
      _trackSettingsButtonPressed(ref, 'delete_error', 'account_deletion_failed');
      showAlert(context, I18nService().t('screen_settings.delete_account_confirmation_error_message', fallback: 'An error occurred while deleting your account'));
    }
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            I18nService().t('screen_settings.delete_account_confirmation_alert_title', fallback: 'Alert'),
            style: AppTheme.getBodyLarge(context),
          ),
          content: Text(
            message,
            style: AppTheme.getBodyMedium(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                I18nService().t('screen_settings.delete_account_confirmation_alert_button', fallback: 'OK'),
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLockWithPin(BuildContext context, WidgetRef ref) async {
    _trackSettingsButtonPressed(ref, 'lock_with_pin', 'pin_lock_initiated');
    final securityVerification = ref.read(securityVerificationProvider.notifier);
    final success = await securityVerification.resetLoadTime();

    if (!context.mounted) return;

    if (success) {
      _trackSettingsButtonPressed(ref, 'lock_success', 'pin_lock_successful');
      context.go(RoutePaths.enterPincode);
    } else {
      _trackSettingsButtonPressed(ref, 'lock_error', 'pin_lock_failed');
      showAlert(context, I18nService().t('screen_settings.delete_account_confirmation_alert_message', fallback: 'An error occurred while deleting your account'));
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    _trackSettingsButtonPressed(ref, 'logout', 'user_logged_out');
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final userExtraAsync = ref.watch(userExtraNotifierProvider);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_settings.settings_header', fallback: 'Settings'),
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: userExtraAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: CustomText(
                text: I18nService().t(
                  'screen_settings.error_loading_settings',
                  fallback: 'Error loading settings: $error',
                  variables: {'error': error.toString()},
                ),
                type: CustomTextType.info,
              ),
            ),
            data: (userExtra) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (userExtra?.onboarding == false) ...[
                  CustomCard(
                    headerText: I18nService().t('screen_settings.my_profile_header', fallback: 'My Profile'),
                    bodyText: I18nService().t('screen_settings.my_profile_description', fallback: 'Edit your name, image and other details'),
                    icon: CardIcon.myProfile,
                    onPressed: () => _handleProfileEdit(context, ref),
                    isAlert: false,
                    backgroundColor: CardBackgroundColor.lightBlue,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomCard(
                    headerText: I18nService().t('screen_settings.security_key_header', fallback: 'Security Key'),
                    bodyText: I18nService().t('screen_settings.security_key_description', fallback: 'Keep your security key safe'),
                    icon: CardIcon.security,
                    onPressed: () {
                      _trackSettingsCardPressed(ref, 'security_key', 'security_key');
                      context.push(RoutePaths.securityKey);
                    },
                    isAlert: false,
                    backgroundColor: CardBackgroundColor.orange,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomCard(
                    headerText: I18nService().t('screen_settings.change_pin_header', fallback: 'Change PIN'),
                    bodyText: I18nService().t('screen_settings.change_pin_description', fallback: 'Update your PIN code to access the app'),
                    icon: CardIcon.dots,
                    onPressed: () {
                      _trackSettingsCardPressed(ref, 'change_pin', 'change_pin_code');
                      context.push(RoutePaths.changePinCode);
                    },
                    isAlert: false,
                    backgroundColor: CardBackgroundColor.blue,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                ],
                CustomCard(
                  headerText: I18nService().t('screen_settings.phone_numbers_header', fallback: 'Phone Numbers'),
                  bodyText: I18nService().t('screen_settings.phone_numbers_description', fallback: 'Manage your phone numbers'),
                  icon: CardIcon.phone,
                  onPressed: () {
                    _trackSettingsCardPressed(ref, 'phone_numbers', 'phone_numbers');
                    context.push(RoutePaths.phoneNumbers);
                  },
                  isAlert: false,
                  backgroundColor: CardBackgroundColor.lightBlue,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomCard(
                  headerText: I18nService().t('screen_settings.support_feedback_header', fallback: 'Support & Feedback'),
                  bodyText: I18nService().t('screen_settings.support_feedback_description', fallback: 'We welcome your feedback. Feel free to reach out to us anytime!'),
                  icon: CardIcon.email,
                  onPressed: () => _handleSupport(ref),
                  isAlert: false,
                  backgroundColor: CardBackgroundColor.lightGreen,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomCard(
                  headerText: I18nService().t('screen_settings.delete_account_header', fallback: 'Delete My Account'),
                  bodyText: I18nService().t('screen_settings.delete_account_description', fallback: 'Deleting your account will remove all your data. You\'ll need to confirm to proceed.'),
                  icon: CardIcon.trash,
                  onPressed: () => _handleDeleteAccount(context, ref),
                  isAlert: true,
                  backgroundColor: CardBackgroundColor.gray,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    print('📦 PackageInfo snapshot state: ${snapshot.connectionState}');
                    if (snapshot.hasError) {
                      print('❌ PackageInfo error: ${snapshot.error}');
                      print('❌ PackageInfo error stack trace: ${snapshot.stackTrace}');
                      return const CustomText(
                        text: 'Error loading version info',
                        type: CustomTextType.bread,
                        alignment: CustomTextAlignment.left,
                      );
                    }
                    if (snapshot.hasData) {
                      // print('✅ PackageInfo data received:');
                      // print('   - Version: ${snapshot.data!.version}');
                      // print('   - Build number: ${snapshot.data!.buildNumber}');
                      // print('   - Package name: ${snapshot.data!.packageName}');
                      // print('   - App name: ${snapshot.data!.appName}');
                      return CustomText(
                        text: 'App version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                        type: CustomTextType.bread,
                        alignment: CustomTextAlignment.center,
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomText(
                  text: I18nService().t('screen_settings.lock_with_pin_description', fallback: 'Secure your app with \'Lock with PIN\' for faster access next time, or log out completely to require your email and password for the next login.'),
                  type: CustomTextType.small_bread,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                if (userExtra?.onboarding == false) ...[
                  CustomButton(
                    text: I18nService().t('screen_settings.lock_with_pin_button', fallback: 'Lock with PIN'),
                    onPressed: () => _handleLockWithPin(context, ref),
                    buttonType: CustomButtonType.primary,
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                ],
                CustomButton(
                  text: I18nService().t('screen_settings.log_out_button', fallback: 'Log out'),
                  onPressed: () => _handleLogout(context, ref),
                  buttonType: CustomButtonType.secondary,
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
