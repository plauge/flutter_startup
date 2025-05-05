import '../../exports.dart';
import '../../providers/security_provider.dart';
import '../../providers/auth_delete_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends AuthenticatedScreen {
  SettingsScreen({super.key});

  static Future<SettingsScreen> create() async {
    final screen = SettingsScreen();
    return AuthenticatedScreen.create(screen);
  }

  void _handleProfileEdit(BuildContext context) {
    context.go(RoutePaths.profileEdit);
  }

  void _handleSecurityKey() {
    // TODO: Implement security key handling
  }

  void _handleChangePin() {
    // TODO: Implement PIN change
  }

  void _handleSupport() {
    // TODO: Implement support handling
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: 'Confirm Account Deletion',
            type: CustomTextType.bread,
          ),
          content: CustomText(
            text:
                'Are you sure you want to delete your account? This action cannot be undone.',
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              text: 'Cancel',
              onPressed: () => _handleCancelDelete(context),
              buttonType: CustomButtonType.secondary,
            ),
            CustomButton(
              text: 'Delete Account',
              onPressed: () => _handleConfirmDelete(context, ref),
              buttonType: CustomButtonType.alert,
            ),
          ],
        );
      },
    );
  }

  void _handleCancelDelete(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleConfirmDelete(BuildContext context, WidgetRef ref) async {
    final authDelete = ref.read(authDeleteProvider.notifier);
    final success = await authDelete.deleteUser();

    if (!context.mounted) return;

    if (success) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        context.go(RoutePaths.login);
      }
    } else {
      showAlert(context, 'Der skete en fejl ved sletning af kontoen');
    }
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alert',
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
                'OK',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLockWithPin(BuildContext context, WidgetRef ref) async {
    final securityVerification =
        ref.read(securityVerificationProvider.notifier);
    final success = await securityVerification.resetLoadTime();

    if (!context.mounted) return;

    if (success) {
      context.go(RoutePaths.enterPincode);
    } else {
      showAlert(context, 'Der skete en fejl');
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
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
      appBar: const AuthenticatedAppBar(
        title: 'Settings',
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: userExtraAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: CustomText(
                text: 'Error loading settings: $error',
                type: CustomTextType.info,
              ),
            ),
            data: (userExtra) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (userExtra?.onboarding == false) ...[
                  CustomCard(
                    headerText: 'My Profile',
                    bodyText: 'Edit your name, image and other details',
                    icon: CardIcon.myProfile,
                    onPressed: () => _handleProfileEdit(context),
                    isAlert: false,
                    backgroundColor: CardBackgroundColor.lightBlue,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomCard(
                    headerText: 'Security Key',
                    bodyText: 'Keep your security key safe',
                    icon: CardIcon.dots,
                    onPressed: () => context.push(RoutePaths.securityKey),
                    isAlert: false,
                    backgroundColor: CardBackgroundColor.orange,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomCard(
                    headerText: 'Change PIN',
                    bodyText: 'Update your PIN code to access the app',
                    icon: CardIcon.dots,
                    onPressed: _handleChangePin,
                    isAlert: false,
                    backgroundColor: CardBackgroundColor.blue,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                ],
                CustomCard(
                  headerText: 'Support & Feedback',
                  bodyText:
                      'We welcome your feedback. Feel free to reach out to us anytime!',
                  icon: CardIcon.email,
                  onPressed: _handleSupport,
                  isAlert: false,
                  backgroundColor: CardBackgroundColor.lightGreen,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomCard(
                  headerText: 'Delete My Account',
                  bodyText:
                      'Deleting your account will remove all your data. You\'ll need to confirm to proceed.',
                  icon: CardIcon.trash,
                  onPressed: () => _handleDeleteAccount(context, ref),
                  isAlert: true,
                  backgroundColor: CardBackgroundColor.gray,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    print(
                        '📦 PackageInfo snapshot state: ${snapshot.connectionState}');
                    if (snapshot.hasError) {
                      print('❌ PackageInfo error: ${snapshot.error}');
                      print(
                          '❌ PackageInfo error stack trace: ${snapshot.stackTrace}');
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
                        text:
                            'App version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                        type: CustomTextType.bread,
                        alignment: CustomTextAlignment.center,
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                const CustomText(
                  text:
                      'Secure your app with \'Lock with PIN\' for faster access next time, or log out completely to require your email and password for the next login.',
                  type: CustomTextType.small_bread,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                if (userExtra?.onboarding == false) ...[
                  CustomButton(
                    text: 'Lock with PIN',
                    onPressed: () => _handleLockWithPin(context, ref),
                    buttonType: CustomButtonType.primary,
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                ],
                CustomButton(
                  text: 'Log out',
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
