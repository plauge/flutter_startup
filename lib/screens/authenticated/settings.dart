import '../../exports.dart';

class SettingsScreen extends AuthenticatedScreen {
  SettingsScreen({super.key});

  static Future<SettingsScreen> create() async {
    final screen = SettingsScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Settings',
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                headerText: 'My Profile',
                bodyText: 'Edit your name, image and other details',
                icon: Icons.person,
                onPressed: () {},
                isAlert: false,
                showArrow: true,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomCard(
                headerText: 'Security Key',
                bodyText: 'Keep your security key safe',
                icon: Icons.vpn_key,
                onPressed: () {},
                isAlert: false,
                showArrow: true,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomCard(
                headerText: 'Change PIN',
                bodyText: 'Update your PIN code to access the app',
                icon: Icons.lock,
                onPressed: () {},
                isAlert: false,
                showArrow: true,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomCard(
                headerText: 'Support & Feedback',
                bodyText:
                    'We welcome your feedback. Feel free to reach out to us anytime!',
                icon: Icons.feedback,
                onPressed: () {},
                isAlert: false,
                showArrow: true,
              ),
              Gap(AppDimensionsTheme.getLarge(context)),
              CustomCard(
                headerText: 'Delete My Account',
                bodyText:
                    'Deleting your account will remove all your data. You\'ll need to confirm to proceed.',
                icon: Icons.delete,
                onPressed: () {
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
                            onPressed: () => Navigator.of(context).pop(),
                            buttonType: CustomButtonType.secondary,
                          ),
                          CustomButton(
                            text: 'Delete Account',
                            onPressed: () => Navigator.of(context).pop(),
                            buttonType: CustomButtonType.alert,
                          ),
                        ],
                      );
                    },
                  );
                },
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
              CustomButton(
                text: 'Lock with PIN',
                onPressed: () {},
                buttonType: CustomButtonType.primary,
              ),
              Gap(AppDimensionsTheme.getSmall(context)),
              CustomButton(
                text: 'Log out',
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();

                  if (context.mounted) {
                    context.go(RoutePaths.login);
                  }
                },
                buttonType: CustomButtonType.alert,
                icon: Icons.logout,
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
            ],
          ),
        ),
      ),
    );
  }
}
