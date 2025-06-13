import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
              appBar: const AuthenticatedAppBar(
                title: 'Profile',
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
                                const CustomText(
                                  text: 'Step 4 of 5',
                                  type: CustomTextType.bread,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                                const CustomText(
                                  text: 'About You',
                                  type: CustomTextType.head,
                                  alignment: CustomTextAlignment.center,
                                ),
                                Gap(AppDimensionsTheme.getLarge(context)),
                                const CustomText(
                                  text: 'We need a few basic details to help your contacts recognize your profile.',
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
                                const CustomText(
                                  text: 'First name',
                                  type: CustomTextType.label,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomTextFormField(
                                  controller: firstNameController,
                                  labelText: 'First Name*',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
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
                                const CustomText(
                                  text: 'Lsst name',
                                  type: CustomTextType.label,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomTextFormField(
                                  controller: lastNameController,
                                  labelText: 'Last name',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                const CustomText(
                                  text: 'Company',
                                  type: CustomTextType.label,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomTextFormField(
                                  controller: companyController,
                                  labelText: 'Company (optional)',
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Skjul knapperne når keyboardet er åbent
                        if (MediaQuery.of(context).viewInsets.bottom == 0)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensionsTheme.getMedium(context),
                              vertical: AppDimensionsTheme.getLarge(context),
                            ),
                            child: Column(
                              children: [
                                CustomButton(
                                  onPressed: () => handleSavePressed(
                                    context,
                                    ref,
                                    formKey,
                                    firstNameController.text,
                                    lastNameController.text,
                                    companyController.text,
                                  ),
                                  text: 'Next',
                                  buttonType: CustomButtonType.primary,
                                ),
                                Gap(AppDimensionsTheme.getMedium(context)),
                                CustomButton(
                                  onPressed: () => handleBackStep(context),
                                  text: 'Back',
                                  buttonType: CustomButtonType.secondary,
                                ),
                              ],
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
            SnackBar(content: Text('Error: $error')),
          );
        }
      }
    } else {
      print('⚠️ PersonalInfoScreen: Form validation failed');
    }
  }
}
