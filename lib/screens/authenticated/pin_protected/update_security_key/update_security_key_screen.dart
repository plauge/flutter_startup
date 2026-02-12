import '../../../../exports.dart';
import 'update_security_key_update_action.dart';
import 'update_security_key_reset_dialog.dart';
import 'update_security_key_reset_action.dart';

class UpdateSecurityKeyScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.security);

  UpdateSecurityKeyScreen({super.key}) : super(pin_code_protected: true);

  static Future<UpdateSecurityKeyScreen> create() async {
    final screen = UpdateSecurityKeyScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    log('UpdateSecurityKeyScreen buildAuthenticatedWidget() called');
    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t(
          'screen_update_security_key.title',
          fallback: 'Update Security Key',
        ),
        backRoutePath: '/home',
      ),
      body: GestureDetector(
        onTap: () {
          // Fjern focus fra alle input felter og luk keyboardet
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: AppTheme.getParentContainerStyle(context).applyToContainer(
          child: _UpdateSecurityKeyForm(ref: ref),
        ),
      ),
    );
  }
}

class _UpdateSecurityKeyForm extends StatefulWidget {
  final WidgetRef ref;

  const _UpdateSecurityKeyForm({required this.ref});

  @override
  State<_UpdateSecurityKeyForm> createState() => _UpdateSecurityKeyFormState();
}

class _UpdateSecurityKeyFormState extends State<_UpdateSecurityKeyForm> {
  static final log = scopedLogger(LogCategory.gui);

  final _formKey = GlobalKey<FormState>();
  final _securityKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _securityKeyController.dispose();
    super.dispose();
  }

  Future<void> _updateSecurityKey() async {
    await executeUpdateSecurityKey(
      ref: widget.ref,
      context: context,
      formKey: _formKey,
      securityKeyController: _securityKeyController,
      setLoadingState: (v) => setState(() => _isLoading = v),
      isMounted: () => mounted,
    );
  }

  Future<void> _showResetConfirmDialog() async {
    final confirmed = await showUpdateSecurityKeyResetDialog(context);
    if (confirmed != true) {
      log('_showResetConfirmDialog() - Reset cancelled or dialog dismissed');
      return;
    }
    if (!context.mounted) return;
    log('_showResetConfirmDialog() - Reset confirmed, calling _performReset()');
    await executeUpdateSecurityKeyReset(
      ref: widget.ref,
      context: context,
      setLoadingState: (v) => setState(() => _isLoading = v),
      isMounted: () => mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    log('_UpdateSecurityKeyForm build() called', {'isLoading': _isLoading});
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap(AppDimensionsTheme.of(context).large),

          // Title
          CustomText(
            text: I18nService().t(
              'screen_update_security_key.heading',
              fallback: 'Enter Your Original Security Key',
            ),
            type: CustomTextType.head,
          ),

          Gap(AppDimensionsTheme.of(context).medium),

          // Description
          CustomText(
            text: I18nService().t(
              'screen_update_security_key.description',
              fallback: 'Your security key has been corrupted and no longer works for this account. Find your original security key in your backup and enter it below to restore access.',
            ),
            type: CustomTextType.bread,
          ),

          Gap(AppDimensionsTheme.of(context).large),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  controller: _securityKeyController,
                  labelText: I18nService().t(
                    'screen_update_security_key.input_label',
                    fallback: 'Security Key',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return I18nService().t(
                        'screen_update_security_key.validation_required',
                        fallback: 'Security key is required',
                      );
                    }
                    return null;
                  },
                ),
                Gap(AppDimensionsTheme.of(context).large),
                CustomButton(
                  key: const Key('update_security_key_button'),
                  text: I18nService().t(
                    'screen_update_security_key.update_button',
                    fallback: 'Update',
                  ),
                  onPressed: () {
                    log('Update button pressed - calling _updateSecurityKey()');
                    _updateSecurityKey();
                  },
                  enabled: !_isLoading,
                ),
                Gap(AppDimensionsTheme.of(context).large),

                // Reset security key link
                GestureDetector(
                  key: const Key('reset_security_key_link'),
                  onTap: _showResetConfirmDialog,
                  child: Text(
                    I18nService().t(
                      'screen_update_security_key.reset_link',
                      fallback: 'Reset security key - this will delete all your contacts',
                    ),
                    style: TextStyle(
                      color: const Color.fromARGB(255, 43, 107, 139),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color.fromARGB(255, 43, 107, 139),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Created on: 2024-12-19 15:30
