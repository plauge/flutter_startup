import '../../exports.dart';

class SecurityKeyScreen extends AuthenticatedScreen {
  SecurityKeyScreen();

  static Future<SecurityKeyScreen> create() async {
    final screen = SecurityKeyScreen();
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
        title: 'Security Key',
        backRoutePath: RoutePaths.settings,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Keep your key in\na safe place',
                type: CustomTextType.head,
              ),
              const Gap(16),
              CustomText(
                text: 'Click the button to copy your Security Key',
                type: CustomTextType.bread,
              ),
              const Gap(24),
              CustomButton(
                onPressed: () {
                  // Copy functionality will be added later
                },
                text: 'Copy Security Key',
                buttonType: CustomButtonType.primary,
              ),
              const Gap(24),
              CustomButton(
                onPressed: () {
                  // Read about functionality will be added later
                },
                text: 'Read About Security Keys',
                buttonType: CustomButtonType.secondary,
                icon: Icons.info_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
