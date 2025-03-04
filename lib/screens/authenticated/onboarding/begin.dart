import '../../../exports.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingBeginScreen extends AuthenticatedScreen {
  OnboardingBeginScreen({super.key});

  static Future<OnboardingBeginScreen> create() async {
    final screen = OnboardingBeginScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Welcome'),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text: 'Secure Contacts',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text:
                  'To protect your secure contacts, we\'ll use PIN code verification. We\'ll guide you step-by-step to set up your profile and security features, ensuring a safe and personalized experience.',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.center,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensionsTheme.getMedium(context),
                vertical: AppDimensionsTheme.getLarge(context),
              ),
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () => context.push(RoutePaths.createPin),
                    text: 'Next',
                    buttonType: CustomButtonType.primary,
                  ),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    onPressed: () => context.go('/home'),
                    text: 'Back',
                    buttonType: CustomButtonType.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
