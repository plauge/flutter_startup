import '../../exports.dart';
import '../../../services/i18n_service.dart';

class ForgotPasswordForm extends ConsumerStatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  ConsumerState<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends ConsumerState<ForgotPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final email = _emailController.text.trim();
      final errorMessage = await authNotifier.requestPasswordResetPin(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (errorMessage != null) {
        CustomSnackBar.show(
          context: context,
          text: errorMessage,
          variant: CustomSnackBarVariant.error,
        );
      } else {
        CustomSnackBar.show(
          context: context,
          text: I18nService().t('widgets_auth_forgot_password_form.forgot_password_form_snackbar_pin_code_sent', fallback: 'PIN code sent to your email! Check your inbox.'),
          variant: CustomSnackBarVariant.success,
        );
        _emailController.clear();
        // Navigate to reset password screen with email parameter
        if (mounted) {
          context.go('${RoutePaths.resetPassword}?email=${Uri.encodeComponent(email)}');
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      CustomSnackBar.show(
        context: context,
        text: 'An error occurred: ${e.toString()}',
        variant: CustomSnackBarVariant.error,
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
            text: I18nService().t('widgets_auth_forgot_password_form.forgot_password_form_email', fallback: 'Email'),
            type: CustomTextType.label,
          ),
          Gap(AppDimensionsTheme.getLarge(context)),
          CustomTextFormField(
            key: const Key('forgot_password_email_field'),
            controller: _emailController..text = _isDebugMode ? 'lauge+1@pixelhuset.dk' : '',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return I18nService().t('widgets_auth_forgot_password_form.forgot_password_form_email_validator_empty', fallback: 'Please enter your email');
              }
              if (!value.contains('@') || !value.contains('.')) {
                return I18nService().t('widgets_auth_forgot_password_form.forgot_password_form_email_validator_invalid', fallback: 'Please enter a valid email');
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomButton(
            onPressed: _resetPassword,
            text: _isLoading
                ? I18nService().t('widgets_auth_forgot_password_form.forgot_password_form_button_loading', fallback: 'Sending...')
                : I18nService().t('widgets_auth_forgot_password_form.forgot_password_form_button_reset', fallback: 'Reset password'),
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

// File created: 2024-12-28 at 17:15
