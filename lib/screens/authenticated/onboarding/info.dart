import '../../../exports.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingInfoScreen extends AuthenticatedScreen {
  OnboardingInfoScreen({super.key});

  static Future<OnboardingInfoScreen> create() async {
    final screen = OnboardingInfoScreen();
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
              text: 'Start creating a profile',
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            const CustomText(
              text:
                  'Welcome to our app! We\'ll guide you through setting up your profile and security features to ensure a safe and personalized experience.',
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.left,
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
                    onPressed: () => context.go('/home'),
                    text: 'Cancel',
                    buttonType: CustomButtonType.secondary,
                  ),
                  const Gap(20),
                  CustomButton(
                    onPressed: () => context.push(RoutePaths.createPin),
                    text: 'Start',
                    buttonType: CustomButtonType.primary,
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
