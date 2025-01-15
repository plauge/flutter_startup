import '../../../exports.dart';

class OnboardingComplete extends AuthenticatedScreen {
  OnboardingComplete();

  static Future<OnboardingComplete> create() async {
    final screen = OnboardingComplete();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    print('🏗️ OnboardingComplete: Building screen');
    return Scaffold(
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const CustomText(
                  text: "You've now completed your profile",
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                const CustomText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.only(bottom: AppDimensionsTheme.getLarge(context)),
              child: CustomButton(
                text: "Get started",
                onPressed: () {
                  print('🚀 OnboardingComplete: Navigating to contacts');
                  context.go(RoutePaths.contacts);
                },
                buttonType: CustomButtonType.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
