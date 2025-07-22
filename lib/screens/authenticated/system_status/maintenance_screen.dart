import '../../../../exports.dart';
import 'dart:io'; // Added for Platform detection

class MaintenanceScreen extends AuthenticatedScreen {
  MaintenanceScreen({super.key}) : super(pin_code_protected: false);

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
                      text: 'The system is currently undergoing maintenance. Please try again later.',
                      type: CustomTextType.bread,
                    ),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                final reloadButton = Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CustomButton(
                    key: const Key('maintenance_reload_button'),
                    onPressed: () => context.go(RoutePaths.home),
                    text: 'Reload',
                    buttonType: CustomButtonType.secondary,
                  ),
                );

                return Platform.isAndroid ? SafeArea(top: false, child: reloadButton) : reloadButton;
              },
            ),
          ],
        ),
      ),
    );
  }
}
