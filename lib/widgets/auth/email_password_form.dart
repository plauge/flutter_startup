import '../../exports.dart';
import '../../../services/i18n_service.dart';

class EmailPasswordForm extends ConsumerStatefulWidget {
  const EmailPasswordForm({super.key});
  @override
  ConsumerState<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends ConsumerState<EmailPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() => setState(() => _isPasswordVisible = !_isPasswordVisible);

  bool get _isDebugMode {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final errorMessage = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (errorMessage != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Login successful - the router will handle navigation automatically
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Login successful!'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
            text: I18nService().t('widgets_auth_email_and_password_form.email_and_password_form_email', fallback: 'Email'),
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            key: const Key('login_email_field'),
            controller: _emailController..text = _emailController.text.isEmpty && _isDebugMode ? 'lauge+1@pixelhuset.dk' : _emailController.text,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: I18nService().t('widgets_auth_email_and_password_form.email_and_password_form_password', fallback: 'Password'),
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            key: const Key('login_password_field'),
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              key: const Key('login_password_visibility_button'),
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).primaryColor,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return I18nService().t('widgets_auth_email_and_password_form.email_and_password_form_password_validator_empty', fallback: 'Please enter your password');
              }
              if (value.length < 6) {
                return I18nService().t('widgets_auth_email_and_password_form.email_and_password_form_password_validator_length', fallback: 'Password must be at least 6 characters');
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            key: const Key('email_password_login_button'),
            onPressed: _login,
            text: I18nService().t('widgets_auth_email_and_password_form.email_and_password_form_button_login', fallback: 'Login'),
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
    super.dispose();
  }
}

// Created on 2024-12-27 at 14:30
