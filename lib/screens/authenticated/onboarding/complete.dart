import '../../../exports.dart';
import '../../../services/i18n_service.dart';
import 'dart:io'; // Added for Platform detection

class OnboardingCompleteScreen extends AuthenticatedScreen {
  OnboardingCompleteScreen({super.key}) : super(pin_code_protected: false);

  static Future<OnboardingCompleteScreen> create() async {
    final screen = OnboardingCompleteScreen();
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
      appBar: const AuthenticatedAppBar(title: 'Super'),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                Gap(AppDimensionsTheme.getLarge(context)),
                const CustomText(
                  text: "You've now completed your profile",
                  type: CustomTextType.head,
                  alignment: CustomTextAlignment.center,
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                const CustomText(
                  text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  type: CustomTextType.bread,
                  alignment: CustomTextAlignment.center,
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final getStartedButton = Padding(
                  padding: EdgeInsets.only(bottom: AppDimensionsTheme.getLarge(context)),
                  child: CustomButton(
                    key: const Key('onboarding_complete_get_started_button'),
                    text: "Get started",
                    onPressed: () {
                      print('🚀 OnboardingComplete: Navigating to contacts');
                      context.go(RoutePaths.contacts);
                    },
                    buttonType: CustomButtonType.primary,
                  ),
                );

                return Platform.isAndroid ? SafeArea(top: false, child: getStartedButton) : getStartedButton;
              },
            ),
          ],
        ),
      ),
    );
  }
}
