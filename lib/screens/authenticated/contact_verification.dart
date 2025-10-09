import '../../exports.dart';
import '../../providers/contact_provider.dart';

import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

class ContactVerificationScreen extends AuthenticatedScreen {
  final String contactId;

  ContactVerificationScreen({
    super.key,
    required this.contactId,
  });

  static Future<ContactVerificationScreen> create({
    required String contactId,
  }) async {
    final screen = ContactVerificationScreen(contactId: contactId);
    return AuthenticatedScreen.create(screen);
  }

  void _trackScreenView(WidgetRef ref) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('contact_verification_screen_viewed', {
      'contact_id': contactId,
      'screen': 'contact_verification',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _trackAuthenticationAttempt(WidgetRef ref, String result) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('contact_verification_auth_attempt', {
      'contact_id': contactId,
      'result': result,
      'screen': 'contact_verification',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _trackContactAction(WidgetRef ref, String action) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('contact_verification_action', {
      'contact_id': contactId,
      'action': action,
      'screen': 'contact_verification',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> _testDecryptEncryptedKey(WidgetRef ref, Contact contact) async {
    try {
      // Hent brugerens token
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (token == null) {
        return 'Token er null';
      }

      // Vælg den rigtige encrypted key baseret på om brugeren er initiator eller receiver
      final currentUserId = ref.read(authProvider)?.id;
      final encryptedKey = contact.initiatorUserId == currentUserId ? contact.initiatorEncryptedKey : contact.receiverEncryptedKey;

      if (encryptedKey == null || encryptedKey.isEmpty) {
        return 'Encrypted key er null eller tom';
      }

      // Dekrypter encrypted key med token
      final decryptedKey = await AESGCMEncryptionUtils.decryptString(encryptedKey, token);

      return decryptedKey;
    } catch (e) {
      return 'Fejl: $e';
    }
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // State management for PersistentSwipeButton

    // Check if in debug mode
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());

    // Track screen view
    _trackScreenView(ref);

    // Perform Face ID authentication before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Skip authentication in debug mode
      if (isDebugMode) {
        _trackAuthenticationAttempt(ref, 'debug_mode_skipped');
        // Call the API directly without authentication
        final exists = await ref.read(contactNotifierProvider.notifier).checkContactExists(contactId);
        if (!exists) {
          if (context.mounted) {
            context.go(RoutePaths.contacts);
          }
          return;
        }

        // Load contact data after confirming existence
        await ref.read(contactNotifierProvider.notifier).loadContact(contactId);
        ref.read(contactNotifierProvider.notifier).markAsVisited(contactId);
        return;
      }

      // Normal authentication flow for non-debug mode
      final LocalAuthentication auth = ref.read(localAuthProvider);
      try {
        // Check if biometric authentication is available
        final bool canCheckBiometrics = await auth.canCheckBiometrics;
        final bool isDeviceSupported = await auth.isDeviceSupported();

        print('DEBUG: canCheckBiometrics: $canCheckBiometrics');
        print('DEBUG: isDeviceSupported: $isDeviceSupported');
        print('DEBUG: Platform.isAndroid: ${Platform.isAndroid}');

        if (!canCheckBiometrics || !isDeviceSupported) {
          print('DEBUG: Biometric authentication not available');
          _trackAuthenticationAttempt(ref, 'biometric_not_available');
          if (context.mounted) {
            _showAuthenticationNotAvailableAlert(context);
            context.go('/contacts');
          }
          return;
        }

        // Check available biometrics
        final availableBiometrics = await auth.getAvailableBiometrics();
        print('DEBUG: Available biometrics: $availableBiometrics');

        final bool didAuthenticate = await auth.authenticate(
          localizedReason: Platform.isIOS ? 'Godkend venligst med Face ID' : 'Godkend venligst med biometric authentication',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,
          ),
        );

        if (!didAuthenticate) {
          _trackAuthenticationAttempt(ref, 'authentication_failed');
          if (context.mounted) {
            _showAuthenticationFailedAlert(context);
            context.go('/contacts');
          }
          return;
        }

        _trackAuthenticationAttempt(ref, 'authentication_success');
      } catch (e) {
        print('DEBUG: Authentication exception: $e');
        if (e is PlatformException) {
          print('DEBUG: PlatformException code: ${e.code}');
          print('DEBUG: PlatformException message: ${e.message}');
          print('DEBUG: PlatformException details: ${e.details}');

          if (context.mounted) {
            if (e.code == auth_error.notAvailable) {
              _trackAuthenticationAttempt(ref, 'biometric_not_available_exception');
              _showAuthenticationNotAvailableAlert(context);
            } else if (e.code == auth_error.notEnrolled) {
              _trackAuthenticationAttempt(ref, 'biometric_not_enrolled');
              _showBiometricNotEnrolledAlert(context);
            } else {
              _trackAuthenticationAttempt(ref, 'authentication_exception');
              _showAuthenticationFailedAlert(context);
            }
            context.go('/contacts');
          }
        } else if (context.mounted) {
          _trackAuthenticationAttempt(ref, 'authentication_exception');
          _showAuthenticationFailedAlert(context);
          context.go('/contacts');
        }
        return;
      }

      // Call the API when the widget is built
      final exists = await ref.read(contactNotifierProvider.notifier).checkContactExists(contactId);
      if (!exists) {
        if (context.mounted) {
          context.go(RoutePaths.contacts);
        }
        return;
      }

      // Load contact data after confirming existence
      await ref.read(contactNotifierProvider.notifier).loadContact(contactId);
      ref.read(contactNotifierProvider.notifier).markAsVisited(contactId);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contact_verification.title', fallback: 'Verification'),
        backRoutePath: '/contacts',
        showSettings: false,
        onBeforeBack: () async {
          await ref.read(confirmsConfirmProvider.notifier).confirmsDelete(contactsId: contactId);
        },
        onBeforeHome: () async {
          await ref.read(confirmsConfirmProvider.notifier).confirmsDelete(contactsId: contactId);
        },
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final contactState = ref.watch(contactNotifierProvider);

          return contactState.when(
            data: (contact) => _buildContent(context, contact, ref),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                I18nService().t(
                  'screen_contact_verification.error_loading',
                  fallback: 'Error: $error',
                  variables: {'error': error.toString()},
                ),
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAuthenticationFailedAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          I18nService().t('screen_contact_verification.auth_failed_title', fallback: 'Authentication Failed'),
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          I18nService().t('screen_contact_verification.auth_failed_message', fallback: 'Biometric authentication failed. Redirecting to contacts.'),
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
          ),
        ],
      ),
    );
  }

  void _showAuthenticationNotAvailableAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          I18nService().t('screen_contact_verification.auth_not_available_title', fallback: 'Biometric Authentication Not Available'),
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          I18nService().t('screen_contact_verification.auth_not_available_message', fallback: 'Biometric authentication is not available on your device.'),
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
          ),
        ],
      ),
    );
  }

  void _showBiometricNotEnrolledAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          I18nService().t('screen_contact_verification.auth_not_enrolled_title', fallback: 'Biometric Authentication Not Set Up'),
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          I18nService().t('screen_contact_verification.auth_not_enrolled_message', fallback: 'Biometric authentication is not set up on your device. Please enable it in Settings > Security.'),
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(I18nService().t('screen_contact_verification.ok_button', fallback: 'OK')),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Contact? contact, WidgetRef ref) {
    if (contact == null) {
      return Center(
        child: Text(
          I18nService().t('screen_contact_verification.contact_not_found', fallback: 'Contact not found'),
          style: AppTheme.getBodyMedium(context),
        ),
      );
    }

    return AppTheme.getParentContainerStyle(context).applyToContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 7,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: contact.profileImage.isNotEmpty ? NetworkImage(contact.profileImage) : null,
                            child: contact.profileImage.isEmpty ? const Icon(Icons.person, size: 50) : null,
                          ),
                        ),
                      ],
                    ),

                    Gap(AppDimensionsTheme.getLarge(context)),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        I18nService().t(
                          'screen_contact_verification.security_level',
                          fallback: 'Security Level ${contact.contactType}',
                          variables: {'level': contact.contactType.toString()},
                        ),
                        textAlign: TextAlign.center,
                        style: AppTheme.getBodyMedium(context).copyWith(
                          color: const Color(0xFF0E5D4A),
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),

                    Gap(AppDimensionsTheme.getLarge(context)),

                    CustomText(
                      text: '${contact.firstName}',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    const SizedBox(height: 5),
                    CustomText(
                      text: '${contact.lastName}',
                      type: CustomTextType.head,
                      alignment: CustomTextAlignment.center,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomText(
                      text: contact.company,
                      type: CustomTextType.info400,
                      alignment: CustomTextAlignment.center,
                    ),

                    // const SizedBox(height: 24),
                    // Confirm(
                    //   contactId: contactId,
                    //   contactFirstName: '${contact.firstName}',
                    // ),

                    Gap(AppDimensionsTheme.getLarge(context)),
                    // Container(
                    //   height: 200,
                    //   child: ConfirmV2(
                    //     contactsId: contactId,
                    //   ),
                    // ),

// Her
                    ActionsHolder(
                      contactId: contactId,
                    ),

                    // Debug info - ændr true til false for at skjule
                    if (false) ...[
                      if (contact.initiatorUserId == ref.read(authProvider)?.id)
                        CustomText(
                          text: 'Common key - krypteret: ${contact.initiatorEncryptedKey}',
                          type: CustomTextType.bread,
                          alignment: CustomTextAlignment.center,
                        )
                      else
                        CustomText(
                          text: 'Common key - krypteret: ${contact.receiverEncryptedKey}',
                          type: CustomTextType.bread,
                          alignment: CustomTextAlignment.center,
                        ),
                      Gap(AppDimensionsTheme.getMedium(context)),

                      // Her - Test dekryptering af encrypted key
                      FutureBuilder<String?>(
                        future: _testDecryptEncryptedKey(ref, contact),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return CustomText(
                              text: 'Dekryptering fejlede: ${snapshot.error}',
                              type: CustomTextType.bread,
                              alignment: CustomTextAlignment.center,
                            );
                          }

                          return CustomText(
                            text: 'Common key - dekrypteret: ${snapshot.data ?? "null"}',
                            type: CustomTextType.bread,
                            alignment: CustomTextAlignment.center,
                          );
                        },
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Her - Row flyttet til bunden
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    key: const Key('contact_verification_star_button'),
                    onTap: () {
                      print('UI: Star icon tapped for contact: $contactId');
                      _trackContactAction(ref, 'star_toggle');
                      ref.read(contactNotifierProvider.notifier).toggleStar(contactId);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: SvgPicture.asset(
                              contact.star ? 'assets/icons/contact/star_active.svg' : 'assets/icons/contact/star.svg',
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            I18nService().t('screen_contact_verification.star_button', fallback: 'Star'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF014459),
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        key: const Key('contact_verification_delete_button'),
                        onTap: () async {
                          _trackContactAction(ref, 'delete_attempt');
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                I18nService().t('screen_contact_verification.delete_contact_title', fallback: 'Delete Contact'),
                                style: AppTheme.getBodyMedium(context),
                              ),
                              content: Text(
                                I18nService().t('screen_contact_verification.delete_contact_message', fallback: 'Are you sure you want to delete this contact?'),
                                style: AppTheme.getBodyMedium(context),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(I18nService().t('screen_contact_verification.cancel_button', fallback: 'Cancel')),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(I18nService().t('screen_contact_verification.delete_button', fallback: 'Delete')),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true && context.mounted) {
                            _trackContactAction(ref, 'delete_confirmed');
                            final success = await ref.read(contactNotifierProvider.notifier).deleteContact(contactId);

                            if (success && context.mounted) {
                              _trackContactAction(ref, 'delete_success');
                              context.go('/contacts');
                            } else if (context.mounted) {
                              _trackContactAction(ref, 'delete_failed');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    I18nService().t('screen_contact_verification.delete_failed', fallback: 'Failed to delete contact'),
                                    style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else if (shouldDelete == false) {
                            _trackContactAction(ref, 'delete_cancelled');
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: SvgPicture.asset('assets/icons/contact/delete.svg', width: 48, height: 48, fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                I18nService().t('screen_contact_verification.delete_button', fallback: 'Delete'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF014459),
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
