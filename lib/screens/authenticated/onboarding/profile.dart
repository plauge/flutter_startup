import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../services/i18n_service.dart';

class OnboardingProfileScreen extends AuthenticatedScreen {
  OnboardingProfileScreen({super.key}) : super(pin_code_protected: false);

  // Add GlobalKey for navigation
  static final _navigatorKey = GlobalKey<NavigatorState>();

  static Future<OnboardingProfileScreen> create() async {
    final screen = OnboardingProfileScreen();
    return AuthenticatedScreen.create(screen);
  }

  void handleBackStep(BuildContext context) {
    context.go(RoutePaths.createPin);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => HookBuilder(
          builder: (context) {
            final firstNameController = useTextEditingController();
            final lastNameController = useTextEditingController();
            final companyController = useTextEditingController();
            final formKey = useMemoized(() => GlobalKey<FormState>());

            return Scaffold(
              appBar: AuthenticatedAppBar(
                title: I18nService().t('screen_onboarding_profile.onboarding_profile_header', fallback: 'Profile'),
                backRoutePath: RoutePaths.profileImage,
              ),
              body: GestureDetector(
                onTap: () {
                  // Fjern focus fra alle input felter og luk keyboardet
                  FocusScope.of(context).unfocus();
                },
                child: AppTheme.getParentContainerStyle(context).applyToContainer(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Gap(AppDimensionsTheme.getLarge(context)),
                                CustomText(
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_step', fallback: 'Step 4 of 5'),
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                                CustomText(
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_about_you', fallback: 'About You'),
                                  type: CustomTextType.head,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                                CustomText(
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_description', fallback: 'We need a few basic details to help your contacts recognize your profile.'),
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                                // TextFormField(
                                //   controller: firstNameController,
                                //   decoration:
                                //       AppTheme.getTextFieldDecoration(context)
                                //           .copyWith(
                                //     labelText: 'First Name*',
                                //   ),
                                //   validator: (value) {
                                //     if (value == null || value.isEmpty) {
                                //       return 'Please enter your first name';
                                //     }
                                //     return null;
                                //   },
                                // ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomText(
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_first_name', fallback: 'First name'),
                                  type: CustomTextType.label,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomTextFormField(
                                  controller: firstNameController,
                                  labelText: I18nService().t('screen_onboarding_profile.onboarding_profile_first_name', fallback: 'First Name*'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return I18nService().t('screen_onboarding_profile.onboarding_profile_first_name_error', fallback: 'Please enter your first name');
                                    }
                                    return null;
                                  },
                                ),

                                // TextFormField(
                                //   controller: lastNameController,
                                //   decoration:
                                //       AppTheme.getTextFieldDecoration(context)
                                //           .copyWith(
                                //     labelText: 'Last Name*',
                                //   ),
                                //   validator: (value) {
                                //     if (value == null || value.isEmpty) {
                                //       return 'Please enter your last name';
                                //     }
                                //     return null;
                                //   },
                                // ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomText(
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_last_name', fallback: 'Last name'),
                                  type: CustomTextType.label,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomTextFormField(
                                  controller: lastNameController,
                                  labelText: I18nService().t('screen_onboarding_profile.onboarding_profile_last_name', fallback: 'Last name'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return I18nService().t('screen_onboarding_profile.onboarding_profile_last_name_error', fallback: 'Please enter your last name');
                                    }
                                    return null;
                                  },
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomText(
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_company', fallback: 'Company'),
                                  type: CustomTextType.label,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomTextFormField(
                                  controller: companyController,
                                  labelText: I18nService().t('screen_onboarding_profile.onboarding_profile_company_optional', fallback: 'Company (optional)'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Skjul knapperne når keyboardet er åbent
                        if (MediaQuery.of(context).viewInsets.bottom == 0)
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensionsTheme.getMedium(context),
                                vertical: AppDimensionsTheme.getLarge(context),
                              ),
                              child: Column(
                                children: [
                                  CustomButton(
                                    key: const Key('onboarding_profile_next_button'),
                                    onPressed: () => handleSavePressed(
                                      context,
                                      ref,
                                      formKey,
                                      firstNameController.text,
                                      lastNameController.text,
                                      companyController.text,
                                    ),
                                    text: I18nService().t('screen_onboarding_profile.onboarding_profile_button', fallback: 'Next'),
                                    buttonType: CustomButtonType.primary,
                                  ),
                                  Gap(AppDimensionsTheme.getMedium(context)),
                                  CustomButton(
                                    key: const Key('onboarding_profile_back_button'),
                                    onPressed: () => handleBackStep(context),
                                    text: I18nService().t('screen_onboarding_profile.onboarding_profile_back_button', fallback: 'Back'),
                                    buttonType: CustomButtonType.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> handleSavePressed(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String firstName,
    String lastName,
    String company,
  ) async {
    print('🔄 PersonalInfoScreen: Starting handleSavePressed');
    if (formKey.currentState?.validate() ?? false) {
      try {
        print('✅ PersonalInfoScreen: Form validated');

        // Complete onboarding first
        print('📝 PersonalInfoScreen: Completing onboarding');
        await ref.read(userExtraNotifierProvider.notifier).completeOnboarding(
              firstName,
              lastName,
              company,
            );

        // Use the navigator key for navigation
        print('🚀 PersonalInfoScreen: Attempting navigation to onboarding complete');
        context.go(RoutePaths.profileImage);
      } catch (error) {
        print('❌ PersonalInfoScreen: Error during save: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(I18nService().t(
              'screen_onboarding_profile.onboarding_profile_error_loading_profile',
              fallback: 'Error loading profile: $error',
              variables: {'error': error.toString()},
            ))),
          );
        }
      }
    } else {
      print('⚠️ PersonalInfoScreen: Form validation failed');
    }
  }
}
