import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PersonalInfoScreen extends AuthenticatedScreen {
  PersonalInfoScreen({super.key});

  static Future<PersonalInfoScreen> create() async {
    final screen = PersonalInfoScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return HookBuilder(
      builder: (context) {
        final firstNameController = useTextEditingController();
        final lastNameController = useTextEditingController();
        final companyController = useTextEditingController();
        final formKey = useMemoized(() => GlobalKey<FormState>());

        return Scaffold(
          //appBar: const AuthenticatedAppBar(title: 'Personal Information'),
          appBar: const AuthenticatedAppBar(
            title: 'Create profile',
            backRoutePath: RoutePaths.createPin,
          ),
          body: AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(AppDimensionsTheme.getLarge(context)),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomElevatedButton(
                    onPressed: () => context.go('/home'),
                    text: 'Cancel',
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  TextFormField(
                    controller: firstNameController,
                    decoration:
                        AppTheme.getTextFieldDecoration(context).copyWith(
                      labelText: 'First Name*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastNameController,
                    decoration:
                        AppTheme.getTextFieldDecoration(context).copyWith(
                      labelText: 'Last Name*',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: companyController,
                    decoration:
                        AppTheme.getTextFieldDecoration(context).copyWith(
                      labelText: 'Company',
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        try {
                          final firstName = firstNameController.text;
                          final lastName = lastNameController.text;
                          final company = companyController.text;

                          // Then update the data
                          await ref
                              .read(userExtraNotifierProvider.notifier)
                              .completeOnboarding(
                                firstName,
                                lastName,
                                company,
                              );

                          // Navigate first
                          context.go(RoutePaths.onboardingComplete);
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $error')),
                          );
                        }
                      }
                    },
                    text: 'Save',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
