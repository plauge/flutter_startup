import 'dart:convert';
import '../../exports.dart';
import '../../models/user_storage_data.dart';

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
    log('_updateSecurityKey() - Starting validation');

    if (!_formKey.currentState!.validate()) {
      log('_updateSecurityKey() - Form validation failed');
      return;
    }

    log('_updateSecurityKey() - Form validation passed');
    setState(() {
      _isLoading = true;
    });

    try {
      log('_updateSecurityKey() - Starting security key update process');

      final user = Supabase.instance.client.auth.currentUser;
      final userEmail = user?.email ?? '';
      log('_updateSecurityKey() - Retrieved user info', {'hasUser': user != null, 'email': userEmail.isNotEmpty ? userEmail : 'empty'});

      if (userEmail.isEmpty) {
        log('_updateSecurityKey() - No authenticated user found, throwing exception');
        throw Exception('No authenticated user found');
      }

      final storage = widget.ref.read(storageProvider.notifier);
      log('_updateSecurityKey() - Storage provider retrieved');

      final currentData = await storage.getUserStorageData();
      log('_updateSecurityKey() - Current storage data retrieved', {'itemCount': currentData.length, 'emails': currentData.map((item) => item.email).toList()});

      // Check if user exists in current data
      final existingUserIndex = currentData.indexWhere((item) => item.email == userEmail);
      log('_updateSecurityKey() - User lookup in storage', {'userEmail': userEmail, 'existingUserIndex': existingUserIndex, 'userExists': existingUserIndex >= 0});

      final newTokenKey = _securityKeyController.text.trim();
      log('_updateSecurityKey() - New token key details', {'newTokenLength': newTokenKey.length, 'hasContent': newTokenKey.isNotEmpty});

      // Update the user's token (security key) while keeping email and testkey
      final updatedData = currentData.map((item) {
        if (item.email == userEmail) {
          log('_updateSecurityKey() - Updating user data', {'email': item.email, 'oldTokenLength': item.token?.length ?? 0, 'newTokenLength': newTokenKey.length, 'hasTestkey': item.testkey != null});
          return UserStorageData(
            email: item.email,
            token: newTokenKey,
            testkey: item.testkey,
          );
        }
        return item;
      }).toList();

      log('_updateSecurityKey() - Data transformation completed', {'updatedItemCount': updatedData.length});

      // Convert to JSON for logging and saving
      final jsonData = updatedData.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonData);
      log('_updateSecurityKey() - JSON serialization completed', {'jsonLength': jsonString.length, 'jsonPreview': jsonString.length > 100 ? '${jsonString.substring(0, 100)}...' : jsonString});

      // Save the updated data
      log('_updateSecurityKey() - Starting secure save operation');
      await storage.saveString(
        kUserStorageKey,
        jsonString,
        secure: true,
      );

      log('_updateSecurityKey() - Security key updated successfully - verifying save');

      // Verify the save by reading back the data
      final verificationData = await storage.getUserStorageData();
      final verifiedUser = verificationData.firstWhere((item) => item.email == userEmail, orElse: () => throw Exception('User not found after save'));
      log('_updateSecurityKey() - Save verification completed', {'verifiedTokenLength': verifiedUser.token?.length ?? 0, 'tokenMatches': verifiedUser.token == newTokenKey});

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
        log('_updateSecurityKey() - Attempting to navigate back using context.pop()');
        try {
          context.pop();
          log('_updateSecurityKey() - Successfully navigated back');
        } catch (navError) {
          log('_updateSecurityKey() - Navigation error', {'navError': navError.toString(), 'navErrorType': navError.runtimeType.toString()});
          // Try alternative navigation
          try {
            context.go('/home');
            log('_updateSecurityKey() - Fallback navigation to home successful');
          } catch (fallbackError) {
            log('_updateSecurityKey() - Fallback navigation also failed', {'fallbackError': fallbackError.toString()});
          }
        }
      }
    } catch (error, stackTrace) {
      log('_updateSecurityKey() - Critical error occurred', {'error': error.toString(), 'errorType': error.runtimeType.toString(), 'stackTrace': stackTrace.toString()});

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
      log('_updateSecurityKey() - Finally block reached, cleaning up');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        log('_updateSecurityKey() - Loading state reset to false');
      } else {
        log('_updateSecurityKey() - Widget no longer mounted, skipping state update');
      }
    }
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Created on: 2024-12-19 15:30
