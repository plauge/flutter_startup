import '../../exports.dart';
import '../../services/i18n_service.dart';
import 'package:flutter/services.dart';

enum PinVerificationStep {
  pinInput,
  passwordInput,
}

class ResetPasswordFormPin extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordFormPin({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordFormPin> createState() => _ResetPasswordFormPinState();
}

class _ResetPasswordFormPinState extends ConsumerState<ResetPasswordFormPin> {
  static final log = scopedLogger(LogCategory.other);

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PinVerificationStep _pinVerificationStep = PinVerificationStep.pinInput;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    log('ResetPasswordFormPin.initState - Email: ${widget.email}');
  }

  Future<void> _validatePinAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      log('ResetPasswordFormPin._validatePinAndContinue - PIN validation failed');
      return;
    }

    if (_pinController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18nService().t('widget_reset_password.pin_code_must_be_12_characters', fallback: 'PIN code must be 12 characters')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _pinVerificationStep = PinVerificationStep.passwordInput;
    });
    log('ResetPasswordFormPin._validatePinAndContinue - PIN validated, switching to password input');
  }

  Future<void> _updatePassword() async {
    AppLogger.logSeparator('ResetPasswordFormPin._updatePassword');
    log('ResetPasswordFormPin._updatePassword - Form submission started');

    if (_pinVerificationStep != PinVerificationStep.passwordInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18nService().t('widget_reset_password.pin_code_required', fallback: 'PIN code must be validated first')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      log('ResetPasswordFormPin._updatePassword - Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final result = await authNotifier.resetPasswordWithPin(
        widget.email,
        _pinController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result != null && result['success'] == true) {
        log('ResetPasswordFormPin._updatePassword - Password reset successful, navigating to success screen');
        // Clear all fields before navigation
        _passwordController.clear();
        _confirmPasswordController.clear();
        _pinController.clear();
        // Navigate to success screen
        if (mounted) {
          context.go(RoutePaths.passwordResetSuccess);
        }
      } else {
        log('ResetPasswordFormPin._updatePassword - Password reset failed: ${result?['message'] ?? 'Unknown error'}');
        // Navigate to error screen
        if (mounted) {
          context.go(RoutePaths.passwordResetError);
        }
      }
    } catch (e) {
      log('ResetPasswordFormPin._updatePassword - Error occurred: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to error screen
      if (mounted) {
        context.go(RoutePaths.passwordResetError);
      }
    }
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return I18nService().t('widget_reset_password.pin_code_required', fallback: 'PIN code must be validated first');
    }
    if (value.length != 12) {
      return I18nService().t('widget_reset_password.pin_code_must_be_12_characters', fallback: 'PIN code must be 12 characters');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return I18nService().t('widget_reset_password.please_enter_password', fallback: 'Please enter a password');
    }
    if (value.length < 6) {
      return I18nService().t('widget_reset_password.password_must_be_at_least_6_characters', fallback: 'Password must be at least 6 characters');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return I18nService().t('widget_reset_password.please_confirm_password', fallback: 'Please confirm your password');
    }
    if (value != _passwordController.text) {
      return I18nService().t('widget_reset_password.passwords_do_not_match', fallback: 'Passwords do not match');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logSeparator('ResetPasswordFormPin.build');

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pinVerificationStep == PinVerificationStep.pinInput) ...[
            CustomText(
              text: I18nService().t('widget_reset_password.enter_pin_code_header', fallback: 'Enter PIN Code'),
              type: CustomTextType.head,
            ),
            Gap(AppDimensionsTheme.of(context).medium),
            CustomText(
              text: I18nService().t(
                'widget_reset_password.enter_pin_code_description',
                fallback: 'Enter the PIN code that was sent to your email address.',
                variables: {'email': widget.email},
              ),
              type: CustomTextType.bread,
            ),
            Gap(AppDimensionsTheme.of(context).large),
            CustomTextFormField(
              key: const Key('reset_password_pin_field'),
              controller: _pinController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(12),
              ],
              keyboardType: TextInputType.text,
              labelText: I18nService().t('widget_reset_password.enter_pin_code', fallback: 'Enter PIN Code'),
              validator: _validatePin,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Gap(AppDimensionsTheme.of(context).large),
            CustomButton(
              key: const Key('reset_password_continue_button'),
              onPressed: _validatePinAndContinue,
              text: I18nService().t('widget_reset_password.continue_button', fallback: 'Continue'),
              buttonType: CustomButtonType.primary,
            ),
          ] else ...[
            CustomText(
              text: I18nService().t('widget_reset_password.reset_your_password', fallback: 'Reset Your Password:'),
              type: CustomTextType.helper,
            ),
            Gap(AppDimensionsTheme.of(context).medium),
            CustomTextFormField(
              key: const Key('reset_password_password_field'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              labelText: I18nService().t('widget_reset_password.new_password', fallback: 'New Password'),
              validator: _validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Gap(AppDimensionsTheme.of(context).medium),
            CustomTextFormField(
              key: const Key('reset_password_confirm_password_field'),
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              labelText: I18nService().t('widget_reset_password.confirm_new_password', fallback: 'Confirm New Password'),
              validator: _validateConfirmPassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            Gap(AppDimensionsTheme.of(context).large),
            CustomButton(
              key: const Key('reset_password_update_button'),
              onPressed: _updatePassword,
              text: _isLoading ? I18nService().t('widget_reset_password.updating', fallback: 'Updating...') : I18nService().t('widget_reset_password.update_password', fallback: 'Update Password'),
              buttonType: CustomButtonType.primary,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// File created: 2024-12-28 at 20:00

