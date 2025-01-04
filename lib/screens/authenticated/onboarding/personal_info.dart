import '../../../exports.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
//import '../../../core/widgets/authenticated_app_bar.dart';

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
          appBar: const AuthenticatedAppBar(title: 'Personal Information'),
          body: AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        // TODO: Implement save functionality
                      }
                    },
                    text: 'Save',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
