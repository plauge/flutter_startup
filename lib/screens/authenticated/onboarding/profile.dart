import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../services/i18n_service.dart';
//import '../../../core/widgets/screens/authenticated_screen_helpers/generate_and_persist_user_token.dart';
import 'dart:io'; // Added for Platform detection

class OnboardingProfileScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
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
                                  text: I18nService().t('screen_onboarding_profile.onboarding_profile_step', fallback: 'Step 3 of 6'),
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
                          Builder(
                            builder: (context) {
                              final profileButtons = Padding(
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
                                    // Gap(AppDimensionsTheme.getMedium(context)),
                                    // CustomButton(
                                    //   key: const Key('onboarding_profile_back_button'),
                                    //   onPressed: () => handleBackStep(context),
                                    //   text: I18nService().t('screen_onboarding_profile.onboarding_profile_back_button', fallback: 'Back'),
                                    //   buttonType: CustomButtonType.secondary,
                                    // ),
                                  ],
                                ),
                              );

                              return Platform.isAndroid ? SafeArea(top: false, child: profileButtons) : profileButtons;
                            },
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
    log('handleSavePressed - Starting');
    if (formKey.currentState?.validate() ?? false) {
      try {
        log('handleSavePressed - Form validated');
        final secretKey = await ref.read(storageProvider.notifier).getCurrentUserToken();
        if (secretKey == null) {
          log('handleSavePressed - No secret key found in storage');
          if (context.mounted) {
            CustomSnackBar.show(
              context: context,
              text: I18nService().t(
                'screen_onboarding_profile.onboarding_profile_error_no_secret_key',
                fallback: 'Could not find security key. Please try again.',
              ),
              variant: CustomSnackBarVariant.error,
            );
          }
          return;
        }
        log('handleSavePressed - Encrypting profile fields');
        final encryptedFirstName = await AESGCMEncryptionUtils.encryptString(firstName, secretKey);
        final encryptedLastName = await AESGCMEncryptionUtils.encryptString(lastName, secretKey);
        final encryptedCompany = await AESGCMEncryptionUtils.encryptString(company, secretKey);
        log('handleSavePressed - Completing onboarding');
        await ref.read(userExtraNotifierProvider.notifier).completeOnboarding(
              firstName: firstName,
              lastName: lastName,
              company: company,
              encryptedFirstName: encryptedFirstName,
              encryptedLastName: encryptedLastName,
              encryptedCompany: encryptedCompany,
            );
        log('handleSavePressed - Navigating to phone number step');
        context.go(RoutePaths.phoneNumber);
      } catch (error) {
        log('handleSavePressed - Error during save: $error');
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            text: I18nService().t(
              'screen_onboarding_profile.onboarding_profile_error_loading_profile',
              fallback: 'Error loading profile: $error',
              variables: {'error': error.toString()},
            ),
            variant: CustomSnackBarVariant.error,
          );
        }
      }
    } else {
      log('handleSavePressed - Form validation failed');
    }
  }
}
