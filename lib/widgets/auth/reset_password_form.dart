import '../../exports.dart';
import '../../providers/supabase_service_provider.dart';

class ResetPasswordForm extends ConsumerStatefulWidget {
  final String? token;
  final String? email;

  const ResetPasswordForm({
    super.key,
    this.token,
    this.email,
  });

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  static final log = scopedLogger(LogCategory.other);

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    log('ResetPasswordForm.initState - Token: ${widget.token != null ? "found" : "missing"}, Email: ${widget.email ?? "missing"}');
  }

  Future<void> _updatePassword() async {
    AppLogger.logSeparator('ResetPasswordForm._updatePassword');
    log('ResetPasswordForm._updatePassword - Form submission started');

    if (widget.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reset token found. Please use the link from your email.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      log('ResetPasswordForm._updatePassword - Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      log('ResetPasswordForm._updatePassword - Building Supabase URL format with code parameter for PKCE flow');

      // Supabase uses PKCE flow and expects code parameter, not access_token
      // Format: scheme://host/path?code=TOKEN&type=recovery
      final queryParams = GoRouterState.of(context).queryParameters;

      // Build URL with code in query parameters (PKCE flow)
      final baseUrl = 'idtruster://reset-password';
      final queryBuilder = StringBuffer();

      // Add code (our token parameter becomes code)
      queryBuilder.write('code=${Uri.encodeComponent(widget.token!)}');

      // Add type=recovery for password reset
      queryBuilder.write('&type=recovery');

      // Add other parameters if they exist (not needed for PKCE flow)
      // PKCE only needs code and type parameters

      // Build complete URL with query parameters
      final uriString = '$baseUrl?${queryBuilder.toString()}';
      final uri = Uri.parse(uriString);

      log('ResetPasswordForm._updatePassword - Built Supabase URL: $uri');

      final supabaseService = ref.read(supabaseServiceProvider);
      final errorMessage = await supabaseService.handleResetPasswordFromUrl(
        uri,
        _passwordController.text,
      );

      log('ResetPasswordForm._updatePassword - Error message: $errorMessage');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (errorMessage == null) {
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Show success message and let auth system handle navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Password updated successfully! Redirecting...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // No manual navigation needed - auth state will automatically redirect to home
        log('ResetPasswordForm._updatePassword - Password reset successful, auth will handle redirect');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password update failed: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('ResetPasswordForm._updatePassword - Error occurred: $e');

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logSeparator('ResetPasswordForm.build');

    if (widget.token == null) {
      return Container(
        padding: EdgeInsets.all(AppDimensionsTheme.of(context).medium),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: '❌ No Reset Token',
              type: CustomTextType.helper,
            ),
            Gap(AppDimensionsTheme.of(context).small),
            const CustomText(
              text: 'No reset token found in the URL. Please use the link from your email.',
              type: CustomTextType.bread,
            ),
            Gap(AppDimensionsTheme.of(context).medium),
            CustomButton(
              onPressed: () => context.go(RoutePaths.forgotPassword),
              text: 'Request New Reset Link',
              buttonType: CustomButtonType.secondary,
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensionsTheme.of(context).medium),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const CustomText(
              text: '✅ Reset token found! Enter your new password below.',
              type: CustomTextType.helper,
            ),
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
            labelText: 'New Password',
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
            labelText: 'Confirm New Password',
            validator: _validateConfirmPassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          Gap(AppDimensionsTheme.of(context).large),
          CustomButton(
            onPressed: _updatePassword,
            text: _isLoading ? 'Updating...' : 'Update Password',
            buttonType: CustomButtonType.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// File created: 2024-12-28 at 18:45
