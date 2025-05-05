import '../../../exports.dart';

class FormScreen extends AuthenticatedScreen {
  FormScreen();

  static Future<FormScreen> create() async {
    final screen = FormScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    return const FormScreenContent();
  }
}

class FormScreenContent extends StatefulWidget {
  const FormScreenContent();

  @override
  State<FormScreenContent> createState() => _FormScreenContentState();
}

class _FormScreenContentState extends State<FormScreenContent> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.push(
        RoutePaths.testResult,
        extra: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthenticatedAppBar(title: 'Test Form'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextFormField(
                controller: _firstNameController,
                labelText: 'First Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const Gap(16),
              CustomTextFormField(
                controller: _lastNameController,
                labelText: 'Last Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const Gap(32),
              CustomButton(
                onPressed: () => _onSave(context),
                text: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
