import '../../exports.dart';
import '../../../services/i18n_service.dart';

class CreateUserForm extends ConsumerStatefulWidget {
  const CreateUserForm({super.key});
  @override
  ConsumerState<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends ConsumerState<CreateUserForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get _isDebugMode {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  @override
  void initState() {
    super.initState();
    // Initialize debug email only once in initState
    if (_isDebugMode) {
      _emailController.text = 'lauge+1@pixelhuset.dk';
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final errorMessage = await authNotifier.createUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (errorMessage == null) {
        // Success - navigate to check email screen
        final emailToSend = _emailController.text.trim();
        print('🔍 CreateUserForm - Navigating to CheckEmailScreen with email: $emailToSend');
        context.go(RoutePaths.checkEmail, extra: emailToSend);
      } else {
        // Error occurred
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating account: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: I18nService().t('widgets_auth_create_user_form.create_user_form_email', fallback: 'Email'),
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            key: const Key('create_user_email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            labelText: I18nService().t('widgets_auth_create_user_form.create_user_form_email', fallback: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return I18nService().t('widgets_auth_create_user_form.create_user_form_email_validator_empty', fallback: 'Please enter your email');
              }
              if (!value.contains('@') || !value.contains('.')) {
                return I18nService().t('widgets_auth_create_user_form.create_user_form_email_validator_invalid', fallback: 'Please enter a valid email');
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: I18nService().t('widgets_auth_create_user_form.create_user_form_password', fallback: 'Password'),
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            key: const Key('create_user_password_field'),
            controller: _passwordController,
            obscureText: true,
            labelText: I18nService().t('widgets_auth_create_user_form.create_user_form_password', fallback: 'Password'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return I18nService().t('widgets_auth_create_user_form.create_user_form_password_validator_empty', fallback: 'Please enter your password');
              }
              if (value.length < 6) {
                return I18nService().t('widgets_auth_create_user_form.create_user_form_password_validator_length', fallback: 'Password must be at least 6 characters');
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: I18nService().t('widgets_auth_create_user_form.create_user_form_confirm_password', fallback: 'Confirm password'),
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            key: const Key('create_user_confirm_password_field'),
            controller: _confirmPasswordController,
            obscureText: true,
            labelText: I18nService().t('widgets_auth_create_user_form.create_user_form_confirm_password', fallback: 'Confirm password'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return I18nService().t('widgets_auth_create_user_form.create_user_form_confirm_password_validator_empty', fallback: 'Please confirm your password');
              }
              if (value != _passwordController.text) {
                return I18nService().t('widgets_auth_create_user_form.create_user_form_confirm_password_validator_match', fallback: 'Passwords do not match');
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            onPressed: _isLoading ? () {} : () => _createAccount(),
            text: _isLoading
                ? I18nService().t('widgets_auth_create_user_form.create_user_form_button_loading', fallback: 'Creating account...')
                : I18nService().t('widgets_auth_create_user_form.create_user_form_button_create', fallback: 'Create account'),
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Created on 2024-12-27 at 16:30
