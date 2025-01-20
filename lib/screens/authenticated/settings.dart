import '../../exports.dart';

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

  void _handleDeleteAccount(BuildContext context) {
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
              onPressed: () => _handleConfirmDelete(context),
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

  void _handleConfirmDelete(BuildContext context) {
    // TODO: Implement actual account deletion
    Navigator.of(context).pop();
  }

  void _handleLockWithPin() {
    // TODO: Implement PIN lock
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
                    icon: Icons.person,
                    onPressed: () => _handleProfileEdit(context),
                    isAlert: false,
                    showArrow: true,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomCard(
                    headerText: 'Security Key',
                    bodyText: 'Keep your security key safe',
                    icon: Icons.vpn_key,
                    onPressed: () => context.push(RoutePaths.securityKey),
                    isAlert: false,
                    showArrow: true,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomCard(
                    headerText: 'Change PIN',
                    bodyText: 'Update your PIN code to access the app',
                    icon: Icons.lock,
                    onPressed: _handleChangePin,
                    isAlert: false,
                    showArrow: true,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                ],
                CustomCard(
                  headerText: 'Support & Feedback',
                  bodyText:
                      'We welcome your feedback. Feel free to reach out to us anytime!',
                  icon: Icons.feedback,
                  onPressed: _handleSupport,
                  isAlert: false,
                  showArrow: true,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                CustomCard(
                  headerText: 'Delete My Account',
                  bodyText:
                      'Deleting your account will remove all your data. You\'ll need to confirm to proceed.',
                  icon: Icons.delete,
                  onPressed: () => _handleDeleteAccount(context),
                  isAlert: true,
                  showArrow: true,
                ),
                Gap(AppDimensionsTheme.getLarge(context)),
                const CustomText(
                  text:
                      'Secure your app with \'Lock with PIN\' for faster access next time, or log out completely to require your email and password for the next login.',
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.left,
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                if (userExtra?.onboarding == false) ...[
                  CustomButton(
                    text: 'Lock with PIN',
                    onPressed: _handleLockWithPin,
                    buttonType: CustomButtonType.primary,
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                ],
                CustomButton(
                  text: 'Log out',
                  onPressed: () => _handleLogout(context, ref),
                  buttonType: CustomButtonType.alert,
                  icon: Icons.logout,
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
