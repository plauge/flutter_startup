import '../../../exports.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/i18n_service.dart';
import 'dart:io'; // Added for Platform detection

class OnboardingFinishScreen extends AuthenticatedScreen {
  OnboardingFinishScreen({super.key}) : super(pin_code_protected: false);

  static Future<OnboardingFinishScreen> create() async {
    final screen = OnboardingFinishScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Scaffold(
      appBar: AuthenticatedAppBar(title: I18nService().t('screen_onboarding_finish.onboarding_finish_app_bar_header', fallback: ' ')),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_onboarding_finish.onboarding_finish_header', fallback: 'Done!'),
              type: CustomTextType.head,
              alignment: CustomTextAlignment.center,
            ),
            Gap(AppDimensionsTheme.getLarge(context)),
            CustomText(
              text: I18nService().t('screen_onboarding_finish.onboarding_finish_description', fallback: 'You have now created your profile and are ready to use ID-Truster.\n\nYou can always change your settings in Settings.'),
              type: CustomTextType.bread,
              alignment: CustomTextAlignment.left,
            ),
            const Spacer(),
            Builder(
              builder: (context) {
                final onboardingButtons = Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensionsTheme.getMedium(context),
                    vertical: AppDimensionsTheme.getLarge(context),
                  ),
                  child: Column(
                    children: [
                      CustomButton(
                        key: const Key('onboarding_finish_get_started_button'),
                        onPressed: () => context.go(RoutePaths.home),
                        text: I18nService().t('screen_onboarding_finish.onboarding_finish_button', fallback: 'Get Started'),
                        buttonType: CustomButtonType.primary,
                      ),
                    ],
                  ),
                );

                return Platform.isAndroid ? SafeArea(top: false, child: onboardingButtons) : onboardingButtons;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Created on: 2025-01-27
