import 'dart:convert';
import '../../exports.dart';
import '../../models/user_storage_data.dart';

class UpdateSecurityKeyScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      log('update_security_key.dart - _updateSecurityKey() - Starting security key update');

      final user = Supabase.instance.client.auth.currentUser;
      final userEmail = user?.email ?? '';

      if (userEmail.isEmpty) {
        throw Exception('No authenticated user found');
      }

      final storage = widget.ref.read(storageProvider.notifier);
      final currentData = await storage.getUserStorageData();

      // Update the user's token (security key) while keeping email and testkey
      final updatedData = currentData.map((item) {
        if (item.email == userEmail) {
          return UserStorageData(
            email: item.email,
            token: _securityKeyController.text.trim(),
            testkey: item.testkey,
          );
        }
        return item;
      }).toList();

      // Save the updated data
      await storage.saveString(
        kUserStorageKey,
        jsonEncode(updatedData.map((e) => e.toJson()).toList()),
        secure: true,
      );

      log('update_security_key.dart - _updateSecurityKey() - Security key updated successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: I18nService().t(
                'screen_update_security_key.success_message',
                fallback: 'Security key updated successfully',
              ),
              type: CustomTextType.info,
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back or to previous screen
        context.pop();
      }
    } catch (error) {
      log('update_security_key.dart - _updateSecurityKey() - Error: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: I18nService().t(
                'screen_update_security_key.error_message',
                fallback: 'Failed to update security key: $error',
                variables: {'error': error.toString()},
              ),
              type: CustomTextType.info,
            ),
            backgroundColor: AppColors.errorColor(context),
          ),
        );
      }
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
                  text: I18nService().t(
                    'screen_update_security_key.update_button',
                    fallback: 'Update',
                  ),
                  onPressed: () => _updateSecurityKey(),
                  enabled: !_isLoading,
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
