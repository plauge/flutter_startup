import '../../../../exports.dart';

class MaintenanceScreen extends AuthenticatedScreen {
  MaintenanceScreen();

  static Future<MaintenanceScreen> create() async {
    final screen = MaintenanceScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: 'System Maintenance',
                      type: CustomTextType.head,
                    ),
                    Gap(AppDimensionsTheme.getMedium(context)),
                    const CustomText(
                      text:
                          'The system is currently undergoing maintenance. Please try again later.',
                      type: CustomTextType.bread,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomButton(
                onPressed: () => context.go(RoutePaths.home),
                text: 'Reload',
                buttonType: CustomButtonType.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
