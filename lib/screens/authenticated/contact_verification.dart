import '../../exports.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/confirm/confirm.dart';
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

    // Perform Face ID authentication before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Skip authentication in debug mode
      if (isDebugMode) {
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
          if (context.mounted) {
            _showAuthenticationFailedAlert(context);
            context.go('/contacts');
          }
          return;
        }
      } catch (e) {
        print('DEBUG: Authentication exception: $e');
        if (e is PlatformException) {
          print('DEBUG: PlatformException code: ${e.code}');
          print('DEBUG: PlatformException message: ${e.message}');
          print('DEBUG: PlatformException details: ${e.details}');

          if (context.mounted) {
            if (e.code == auth_error.notAvailable) {
              _showAuthenticationNotAvailableAlert(context);
            } else if (e.code == auth_error.notEnrolled) {
              _showBiometricNotEnrolledAlert(context);
            } else {
              _showAuthenticationFailedAlert(context);
            }
            context.go('/contacts');
          }
        } else if (context.mounted) {
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
        title: 'Verification',
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
                'Error: $error',
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
          'Authentication Failed',
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          'Biometric authentication failed. Redirecting to contacts.',
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
          'Biometric Authentication Not Available',
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          'Biometric authentication is not available on your device.',
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
          'Biometric Authentication Not Set Up',
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          'Biometric authentication is not set up on your device. Please enable it in Settings > Security.',
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Contact? contact, WidgetRef ref) {
    if (contact == null) {
      return Center(
        child: Text(
          'Contact not found',
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
                        'Security Level ${contact.contactType}',
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
                    Container(
                      height: 200,
                      child: ConfirmV2(
                        contactsId: contactId,
                      ),
                    ),

                    // if (contact.initiatorUserId == ref.read(authProvider)?.id)
                    //   CustomText(
                    //     text: 'Common key - krypteret: ${contact.initiatorEncryptedKey}',
                    //     type: CustomTextType.bread,
                    //     alignment: CustomTextAlignment.center,
                    //   )
                    // else
                    //   CustomText(
                    //     text: 'Common key - krypteret: ${contact.receiverEncryptedKey}',
                    //     type: CustomTextType.bread,
                    //     alignment: CustomTextAlignment.center,
                    //   ),
                    //Gap(AppDimensionsTheme.getMedium(context)),
                    if (false)
                      FutureBuilder<String?>(
                        future: ref.read(storageProvider.notifier).getCurrentUserToken(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: AppTheme.getBodyMedium(context),
                            );
                          }
                          final secretKey = snapshot.data;
                          if (secretKey == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              if (contact.initiatorUserId == ref.read(authProvider)?.id)
                                FutureBuilder<String>(
                                  future: AESGCMEncryptionUtils.decryptString(contact.initiatorEncryptedKey, secretKey),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text(
                                        'Error: ${snapshot.error}',
                                        style: AppTheme.getBodyMedium(context),
                                      );
                                    }
                                    return CustomText(
                                      text: 'Common key - dekrypteret: ${snapshot.data}',
                                      type: CustomTextType.bread,
                                      alignment: CustomTextAlignment.center,
                                    );
                                  },
                                )
                              else
                                FutureBuilder<String>(
                                  future: AESGCMEncryptionUtils.decryptString(contact.receiverEncryptedKey, secretKey),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text(
                                        'Error: ${snapshot.error}',
                                        style: AppTheme.getBodyMedium(context),
                                      );
                                    }
                                    return CustomText(
                                      text: 'Common key - dekrypteret: ${snapshot.data}',
                                      type: CustomTextType.bread,
                                      alignment: CustomTextAlignment.center,
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),

                    // const CustomText(
                    //   text:
                    //       'To verify a contact, ensure they have you saved as a contact. Ask them to open your card and swipe to confirm.',
                    //   type: CustomTextType.bread,
                    //   alignment: CustomTextAlignment.center,
                    // ),
                    // const SizedBox(height: 24),
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
                            'Star',
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
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Delete Contact',
                                style: AppTheme.getBodyMedium(context),
                              ),
                              content: Text(
                                'Are you sure you want to delete this contact?',
                                style: AppTheme.getBodyMedium(context),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true && context.mounted) {
                            final success = await ref.read(contactNotifierProvider.notifier).deleteContact(contactId);

                            if (success && context.mounted) {
                              context.go('/contacts');
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete contact',
                                    style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
                                'Delete',
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
