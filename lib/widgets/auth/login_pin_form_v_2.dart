import '../../exports.dart';
import '../../services/i18n_service.dart';
import '../../utils/aes_gcm_encryption_utils.dart';
import 'package:flutter/services.dart';

/// LoginPinFormV2 - Version 2 of the login PIN form widget.
///
/// This widget handles changes in the type of password that should be used.
/// Instead of calling auth_request_login_pin_code, this version uses the new
/// provider method auth_request_login_pin_code_v2 to handle updated password requirements.
enum LoginPinStepV2 {
  emailInput,
  pinInput,
}

class LoginPinFormV2 extends ConsumerStatefulWidget {
  final ValueChanged<LoginPinStepV2>? onStepChanged;
  final void Function(VoidCallback)? onBackCallbackReady;

  const LoginPinFormV2({
    super.key,
    this.onStepChanged,
    this.onBackCallbackReady,
  });

  @override
  ConsumerState<LoginPinFormV2> createState() => _LoginPinFormV2State();
}

class _LoginPinFormV2State extends ConsumerState<LoginPinFormV2> {
  static final log = scopedLogger(LogCategory.gui);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _pinFormKey = GlobalKey<FormState>();
  LoginPinStepV2 _currentStep = LoginPinStepV2.emailInput;
  bool _isLoading = false;
  String _storedEmail = '';

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinControllerChanged);
    // Provide back callback to parent if requested
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onBackCallbackReady?.call(goBackToStep1);
      widget.onStepChanged?.call(_currentStep);
    });
  }

  void _onPinControllerChanged() {
    setState(() {
      // Trigger rebuild when PIN controller changes to update button text
    });
  }

  Future<void> _pastePasswordFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final trimmedText = clipboardData!.text!.trim();
        _pinController.text = trimmedText;
        log('LoginPinFormV2._pastePasswordFromClipboard - Pasted password from clipboard (length: ${trimmedText.length})');
      } else {
        log('LoginPinFormV2._pastePasswordFromClipboard - No text found in clipboard');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(I18nService().t(
              'widget_login_pin.no_clipboard_data',
              fallback: 'No text found in clipboard',
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('LoginPinFormV2._pastePasswordFromClipboard - Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18nService().t(
            'widget_login_pin.clipboard_error',
            fallback: 'Error reading from clipboard',
          )),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goBackToStep1() {
    setState(() {
      _currentStep = LoginPinStepV2.emailInput;
      _pinController.clear();
    });
    widget.onStepChanged?.call(_currentStep);
    log('LoginPinFormV2._goBackToStep1 - Returned to step 1');
  }

  void goBackToStep1() {
    _goBackToStep1();
  }

  Future<void> _requestPinCode() async {
    if (!_emailFormKey.currentState!.validate()) {
      log('LoginPinFormV2._requestPinCode - Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final email = _emailController.text.trim();
      final languageCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final errorMessage = await authNotifier.requestLoginPinCodeV2(email, languageCode);

      if (!mounted) return;

      if (errorMessage != null) {
        log('LoginPinFormV2._requestPinCode - Error message received: $errorMessage');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        log('LoginPinFormV2._requestPinCode - No error, switching to step 2');
        setState(() {
          _storedEmail = email;
          _currentStep = LoginPinStepV2.pinInput;
          _isLoading = false;
        });
        widget.onStepChanged?.call(_currentStep);
        log('LoginPinFormV2._requestPinCode - PIN code requested successfully, moved to step 2. Current step: $_currentStep');
      }
    } catch (e) {
      log('LoginPinFormV2._requestPinCode - Error occurred: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeLogin() async {
    if (_currentStep == LoginPinStepV2.pinInput) {
      if (!_pinFormKey.currentState!.validate()) {
        log('LoginPinFormV2._completeLogin - Form validation failed');
        return;
      }
    }

    if (_pinController.text.length != 6 || !RegExp(r'^\d+$').hasMatch(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN code must be exactly 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final pin = _pinController.text.trim();

      // Generate secure 32-character password
      final generatedPassword = AESGCMEncryptionUtils.generateSecurePassword32();
      log('LoginPinFormV2._completeLogin - Generated secure password (length: ${generatedPassword.length})');
      log('LoginPinFormV2._completeLogin - Password contains special chars: ${generatedPassword.contains(RegExp(r'[^a-zA-Z0-9]'))}');

      // Call resetPasswordOrCreateUser
      log('LoginPinFormV2._completeLogin - Calling resetPasswordOrCreateUser with email: $_storedEmail, pin length: ${pin.length}');
      final result = await authNotifier.resetPasswordOrCreateUser(
        _storedEmail,
        pin,
        generatedPassword,
      );

      if (!mounted) {
        log('LoginPinFormV2._completeLogin - Widget not mounted, returning');
        return;
      }

      log('LoginPinFormV2._completeLogin - Result received: $result');
      log('LoginPinFormV2._completeLogin - Result is null: ${result == null}');
      if (result != null) {
        log('LoginPinFormV2._completeLogin - Result success: ${result['success']}');
        log('LoginPinFormV2._completeLogin - Result keys: ${result.keys.toList()}');
      }

      if (result != null && result['success'] == true) {
        final action = result['action'] as String?;
        log('LoginPinFormV2._completeLogin - Password reset/create successful, action: $action (type: ${action.runtimeType})');

        // Check if backend automatically logged us in
        final supabaseService = SupabaseService();
        final currentUserBeforeLogin = await supabaseService.getCurrentUser();
        if (currentUserBeforeLogin != null) {
          log('LoginPinFormV2._completeLogin - Backend automatically logged in user: ${currentUserBeforeLogin.email}');
          // User is already logged in, router will handle navigation
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Handle different actions
        log('LoginPinFormV2._completeLogin - Action received: $action');

        if (action == 'user_created') {
          log('LoginPinFormV2._completeLogin - New user created, proceeding to login');
          log('LoginPinFormV2._completeLogin - Attempting login with email and generated password (new user)');
          log('LoginPinFormV2._completeLogin - Email: $_storedEmail, Password length: ${generatedPassword.length}');
        } else if (action == 'password_reset') {
          log('LoginPinFormV2._completeLogin - Password reset, attempting login immediately');
          log('LoginPinFormV2._completeLogin - Email: $_storedEmail, Password length: ${generatedPassword.length}');
        } else {
          log('LoginPinFormV2._completeLogin - Unknown action: $action, attempting login immediately');
        }

        // Attempt to login with email and generated password
        final loginErrorMessage = await authNotifier.login(
          _storedEmail,
          generatedPassword,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (loginErrorMessage != null) {
          log('LoginPinFormV2._completeLogin - Login failed after successful password reset: $loginErrorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginErrorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          log('LoginPinFormV2._completeLogin - Login successful, router will handle navigation');
          // Router handles navigation automatically - no manual navigation needed
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        final errorMessage = result?['message'] ?? 'Unknown error occurred';
        log('LoginPinFormV2._completeLogin - Password reset/create failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('LoginPinFormV2._completeLogin - Error occurred: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the PIN code';
    }
    if (value.length != 6) {
      return 'PIN code must be exactly 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN code must contain only numbers';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Cache I18nService translations to avoid multiple calls and log spam
    final i18n = I18nService();
    final insertPasswordButtonText = i18n.t('widget_login_pin.insert_password_button', fallback: 'Insert password');
    final loginButtonText2 = i18n.t('widget_login_pin.login_button', fallback: 'Log in');
    final emailHelperText = i18n.t(
      'widget_login_pin.email_helper_text',
      fallback: "Enter your email. We'll send you a one-time password.",
    );
    final pinHelperText = i18n.t(
      'widget_login_pin.pin_helper_text',
      fallback: 'Check your email and paste the one-time password here.',
    );
    final enterPinCodeLabel = i18n.t(
      'widget_login_pin.enter_pin_code',
      fallback: 'Insert one-time password',
    );
    final emailHintText = i18n.t(
      'widget_login_pin.email_hint',
      fallback: 'Enter your email address',
    );
    final pinHintText = i18n.t(
      'widget_login_pin.pin_hint',
      fallback: 'Enter the 6-digit PIN code',
    );
    final getPasswordButtonText = i18n.t('widget_login_pin.get_password_button', fallback: 'Send password');
    final emailLabelText = i18n.t('widget_login_pin.email_label', fallback: 'Email');
    final pinLabelText = i18n.t('widget_login_pin.pin_label', fallback: 'PIN Code');

    // Determine button text, action, and type for step 2
    final bool hasPinText = _pinController.text.trim().isNotEmpty;
    final String step2ButtonText = hasPinText ? loginButtonText2 : insertPasswordButtonText;
    final VoidCallback step2ButtonAction = hasPinText ? _completeLogin : _pastePasswordFromClipboard;
    final CustomButtonType step2ButtonType = hasPinText ? CustomButtonType.primary : CustomButtonType.secondary;

    return AutofillGroup(
      child: _currentStep == LoginPinStepV2.emailInput
          ? Form(
              key: _emailFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHelpText(
                    text: emailHelperText,
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomText(
                    text: emailLabelText,
                    type: CustomTextType.label,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomTextFormField(
                    key: const Key('login_pin_email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    hintText: emailHintText,
                  ),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    key: const Key('login_pin_request_button'),
                    onPressed: _requestPinCode,
                    enabled: !_isLoading,
                    text: getPasswordButtonText,
                    buttonType: CustomButtonType.primary,
                  ),
                ],
              ),
            )
          : Form(
              key: _pinFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHelpText(
                    text: pinHelperText,
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomText(
                    text: pinLabelText,
                    type: CustomTextType.label,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomTextFormField(
                    key: const Key('login_pin_code_field'),
                    controller: _pinController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    keyboardType: TextInputType.number,
                    labelText: enterPinCodeLabel,
                    hintText: pinHintText,
                    validator: _validatePin,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    showClearButton: true,
                  ),
                  Gap(AppDimensionsTheme.getMedium(context)),
                  CustomButton(
                    key: const Key('login_pin_step2_button'),
                    onPressed: step2ButtonAction,
                    enabled: !_isLoading,
                    text: step2ButtonText,
                    buttonType: step2ButtonType,
                  ),
                  // Gap(AppDimensionsTheme.getLarge(context)),
                  // Gap(AppDimensionsTheme.getLarge(context)),
                  // CustomButton(
                  //   key: const Key('login_pin_back_button'),
                  //   onPressed: _goBackToStep1,
                  //   enabled: !_isLoading,
                  //   text: backButtonText,
                  //   buttonType: CustomButtonType.secondary,
                  // ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinControllerChanged);
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}

// File created: 2025-01-27 16:45
