import '../../exports.dart';
import '../../services/i18n_service.dart';
import '../../utils/aes_gcm_encryption_utils.dart';
import 'package:flutter/services.dart';

enum LoginPinStep {
  emailInput,
  pinInput,
}

class LoginPinForm extends ConsumerStatefulWidget {
  const LoginPinForm({super.key});

  @override
  ConsumerState<LoginPinForm> createState() => _LoginPinFormState();
}

class _LoginPinFormState extends ConsumerState<LoginPinForm> {
  static final log = scopedLogger(LogCategory.gui);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _pinFormKey = GlobalKey<FormState>();
  LoginPinStep _currentStep = LoginPinStep.emailInput;
  bool _isLoading = false;
  String _storedEmail = '';

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinControllerChanged);
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
        log('LoginPinForm._pastePasswordFromClipboard - Pasted password from clipboard (length: ${trimmedText.length})');
      } else {
        log('LoginPinForm._pastePasswordFromClipboard - No text found in clipboard');
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
      log('LoginPinForm._pastePasswordFromClipboard - Error occurred: $e');
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
      _currentStep = LoginPinStep.emailInput;
      _pinController.clear();
    });
    log('LoginPinForm._goBackToStep1 - Returned to step 1');
  }

  Future<void> _requestPinCode() async {
    if (!_emailFormKey.currentState!.validate()) {
      log('LoginPinForm._requestPinCode - Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final email = _emailController.text.trim();
      final languageCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final errorMessage = await authNotifier.requestLoginPinCode(email, languageCode);

      if (!mounted) return;

      if (errorMessage != null) {
        log('LoginPinForm._requestPinCode - Error message received: $errorMessage');
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
        log('LoginPinForm._requestPinCode - No error, switching to step 2');
        setState(() {
          _storedEmail = email;
          _currentStep = LoginPinStep.pinInput;
          _isLoading = false;
        });
        log('LoginPinForm._requestPinCode - PIN code requested successfully, moved to step 2. Current step: $_currentStep');
      }
    } catch (e) {
      log('LoginPinForm._requestPinCode - Error occurred: $e');
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
    if (_currentStep == LoginPinStep.pinInput) {
      if (!_pinFormKey.currentState!.validate()) {
        log('LoginPinForm._completeLogin - Form validation failed');
        return;
      }
    }

    if (_pinController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PIN code must be at least 6 characters'),
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
      log('LoginPinForm._completeLogin - Generated secure password (length: ${generatedPassword.length})');
      log('LoginPinForm._completeLogin - Password contains special chars: ${generatedPassword.contains(RegExp(r'[^a-zA-Z0-9]'))}');

      // Call resetPasswordOrCreateUser
      log('LoginPinForm._completeLogin - Calling resetPasswordOrCreateUser with email: $_storedEmail, pin length: ${pin.length}');
      final result = await authNotifier.resetPasswordOrCreateUser(
        _storedEmail,
        pin,
        generatedPassword,
      );

      if (!mounted) {
        log('LoginPinForm._completeLogin - Widget not mounted, returning');
        return;
      }

      log('LoginPinForm._completeLogin - Result received: $result');
      log('LoginPinForm._completeLogin - Result is null: ${result == null}');
      if (result != null) {
        log('LoginPinForm._completeLogin - Result success: ${result['success']}');
        log('LoginPinForm._completeLogin - Result keys: ${result.keys.toList()}');
      }

      if (result != null && result['success'] == true) {
        final action = result['action'] as String?;
        log('LoginPinForm._completeLogin - Password reset/create successful, action: $action (type: ${action.runtimeType})');

        // Check if backend automatically logged us in
        final supabaseService = SupabaseService();
        final currentUserBeforeLogin = await supabaseService.getCurrentUser();
        if (currentUserBeforeLogin != null) {
          log('LoginPinForm._completeLogin - Backend automatically logged in user: ${currentUserBeforeLogin.email}');
          // User is already logged in, router will handle navigation
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Handle different actions
        log('LoginPinForm._completeLogin - Action received: $action');

        if (action == 'user_created') {
          log('LoginPinForm._completeLogin - New user created, proceeding to login');
          log('LoginPinForm._completeLogin - Attempting login with email and generated password (new user)');
          log('LoginPinForm._completeLogin - Email: $_storedEmail, Password length: ${generatedPassword.length}');
        } else if (action == 'password_reset') {
          log('LoginPinForm._completeLogin - Password reset, attempting login immediately');
          log('LoginPinForm._completeLogin - Email: $_storedEmail, Password length: ${generatedPassword.length}');
        } else {
          log('LoginPinForm._completeLogin - Unknown action: $action, attempting login immediately');
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
          log('LoginPinForm._completeLogin - Login failed after successful password reset: $loginErrorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginErrorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          log('LoginPinForm._completeLogin - Login successful, router will handle navigation');
          // Router handles navigation automatically - no manual navigation needed
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        final errorMessage = result?['message'] ?? 'Unknown error occurred';
        log('LoginPinForm._completeLogin - Password reset/create failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('LoginPinForm._completeLogin - Error occurred: $e');
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
    if (value.length < 6) {
      return 'PIN code must be at least 6 characters';
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
      fallback: 'Enter your email. We’ll send you a one-time password.',
    );
    final pinHelperText = i18n.t(
      'widget_login_pin.pin_helper_text',
      fallback: 'Check your email and paste the one-time password here.',
    );
    final enterPinCodeLabel = i18n.t(
      'widget_login_pin.enter_pin_code',
      fallback: 'Enter one-time password',
    );
    final emailHintText = i18n.t(
      'widget_login_pin.email_hint',
      fallback: 'Enter your email address',
    );
    final pinHintText = i18n.t(
      'widget_login_pin.pin_hint',
      fallback: 'Enter the 12-digit password',
    );
    final backButtonText = i18n.t('widget_login_pin.back_button', fallback: 'Back');
    final getPasswordButtonText = i18n.t('widget_login_pin.get_password_button', fallback: 'Send password');

    // Determine button text and action for step 2
    final bool hasPinText = _pinController.text.trim().isNotEmpty;
    final String step2ButtonText = hasPinText ? loginButtonText2 : insertPasswordButtonText;
    final VoidCallback step2ButtonAction = hasPinText ? _completeLogin : _pastePasswordFromClipboard;

    return AutofillGroup(
      child: _currentStep == LoginPinStep.emailInput
          ? Form(
              key: _emailFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHelpText(
                    text: emailHelperText,
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  const CustomText(
                    text: 'Email',
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomHelpText(
                    text: pinHelperText,
                    type: CustomTextType.helper,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomTextFormField(
                    key: const Key('login_pin_code_field'),
                    controller: _pinController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                    ],
                    keyboardType: TextInputType.text,
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
                    buttonType: CustomButtonType.primary,
                  ),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  Gap(AppDimensionsTheme.getLarge(context)),
                  CustomButton(
                    key: const Key('login_pin_back_button'),
                    onPressed: _goBackToStep1,
                    enabled: !_isLoading,
                    text: backButtonText,
                    buttonType: CustomButtonType.secondary,
                  ),
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

// File created: 2025-01-27
