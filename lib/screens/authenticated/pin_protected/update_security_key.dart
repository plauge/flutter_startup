import 'dart:convert';
import '../../../exports.dart';
import '../../../models/user_storage_data.dart';
import '../../../providers/security_reset_provider.dart';
import '../../../core/widgets/screens/authenticated_screen_helpers/generate_and_persist_user_token.dart';

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
      final userExists = existingUserIndex >= 0;
      log('_updateSecurityKey() - User lookup in storage', {'userEmail': userEmail, 'existingUserIndex': existingUserIndex, 'userExists': userExists});

      final newTokenKey = _securityKeyController.text.trim();
      log('_updateSecurityKey() - New token key details', {'newTokenLength': newTokenKey.length, 'hasContent': newTokenKey.isNotEmpty});

      // Update the user's token (security key) while keeping email and testkey, or create new user if not exists
      List<UserStorageData> updatedData;
      if (userExists) {
        // Update existing user
        updatedData = currentData.map((item) {
          if (item.email == userEmail) {
            log('_updateSecurityKey() - Updating existing user data', {'email': item.email, 'oldTokenLength': item.token.length, 'newTokenLength': newTokenKey.length, 'hasTestkey': item.testkey.isNotEmpty});
            return UserStorageData(
              email: item.email,
              token: newTokenKey,
              testkey: item.testkey,
            );
          }
          return item;
        }).toList();
      } else {
        // Create new user entry
        log('_updateSecurityKey() - User not found, creating new user entry', {'email': userEmail, 'newTokenLength': newTokenKey.length});
        final newUserData = UserStorageData(
          email: userEmail,
          token: newTokenKey,
          testkey: AESGCMEncryptionUtils.generateSecureTestKey(),
        );
        updatedData = [...currentData, newUserData];
        log('_updateSecurityKey() - New user entry created', {'totalItems': updatedData.length});
      }

      log('_updateSecurityKey() - Data transformation completed', {'updatedItemCount': updatedData.length, 'userWasCreated': !userExists});

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
      log('_updateSecurityKey() - Save verification completed', {'verifiedTokenLength': verifiedUser.token.length, 'tokenMatches': verifiedUser.token == newTokenKey});

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

  Future<void> _showResetConfirmDialog() async {
    log('_showResetConfirmDialog() - Showing reset confirmation dialog');

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: I18nService().t(
              'screen_update_security_key.reset_dialog_title',
              fallback: 'Reset Security Key',
            ),
            type: CustomTextType.head,
          ),
          content: CustomText(
            text: I18nService().t(
              'screen_update_security_key.reset_dialog_content',
              fallback: 'This action will permanently delete all your contacts and reset your security key. This cannot be undone.\n\nAre you sure you want to continue?',
            ),
            type: CustomTextType.bread,
          ),
          actions: [
            CustomButton(
              key: const Key('reset_dialog_cancel_button'),
              text: I18nService().t(
                'screen_update_security_key.reset_dialog_cancel',
                fallback: 'Cancel',
              ),
              onPressed: () {
                log('_showResetConfirmDialog() - User cancelled reset');
                Navigator.of(context).pop(false);
              },
            ),
            CustomText(
              text: '        ',
              type: CustomTextType.bread,
            ),
            CustomButton(
              key: const Key('reset_dialog_confirm_button'),
              buttonType: CustomButtonType.secondary,
              text: I18nService().t(
                'screen_update_security_key.reset_dialog_confirm',
                fallback: 'Reset',
              ),
              onPressed: () {
                log('_showResetConfirmDialog() - User confirmed reset');
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      log('_showResetConfirmDialog() - Reset confirmed, calling _performReset()');
      // TODO: Implement reset functionality later
      _performReset();
    } else {
      log('_showResetConfirmDialog() - Reset cancelled or dialog dismissed');
    }
  }

  Future<void> _performReset() async {
    log('_performReset() - Starting security token reset');

    setState(() {
      _isLoading = true;
    });

    try {
      final securityResetNotifier = widget.ref.read(securityResetProvider.notifier);
      final success = await securityResetNotifier.resetSecurityTokenData();

      log('_performReset() - Reset operation completed', {'success': success});

      if (success) {
        // Generate new user token and update user_extra after successful reset
        log('_performReset() - Generating new user token and updating user_extra');
        await generateAndPersistUserToken(widget.ref);
        log('_performReset() - User token generated and user_extra updated successfully');
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: I18nService().t(
                  'screen_update_security_key.reset_success_message',
                  fallback: 'Security key reset successfully. All contacts have been deleted.',
                ),
                type: CustomTextType.info,
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate back to home
          log('_performReset() - Attempting to navigate back to home');
          try {
            context.go('/home');
            log('_performReset() - Successfully navigated to home');
          } catch (navError) {
            log('_performReset() - Navigation error', {'navError': navError.toString()});
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: I18nService().t(
                  'screen_update_security_key.reset_failed_message',
                  fallback: 'Failed to reset security key. Please try again.',
                ),
                type: CustomTextType.info,
              ),
              backgroundColor: AppColors.errorColor(context),
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      log('_performReset() - Critical error occurred', {'error': error.toString(), 'errorType': error.runtimeType.toString(), 'stackTrace': stackTrace.toString()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: I18nService().t(
                'screen_update_security_key.reset_error_message',
                fallback: 'Error during reset: $error',
                variables: {'error': error.toString()},
              ),
              type: CustomTextType.info,
            ),
            backgroundColor: AppColors.errorColor(context),
          ),
        );
      }
    } finally {
      log('_performReset() - Finally block reached, cleaning up');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        log('_performReset() - Loading state reset to false');
      } else {
        log('_performReset() - Widget no longer mounted, skipping state update');
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
