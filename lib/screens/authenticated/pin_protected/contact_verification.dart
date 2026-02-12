import '../../../exports.dart';
import '../../../providers/contact_provider.dart';

import 'package:flutter_svg/flutter_svg.dart';

final _contactLoadedProvider = StateProvider.autoDispose.family<bool, String>((ref, contactId) => false);
final _contactLoadingProvider = StateProvider.autoDispose.family<bool, String>((ref, contactId) => false);

class ContactVerificationScreen extends AuthenticatedScreen {
  final String contactId;
  static final log = scopedLogger(LogCategory.gui);

  ContactVerificationScreen({
    super.key,
    required this.contactId,
  }) : super(face_id_protected: true);

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
    _trackScreenView(ref);
    log('buildAuthenticatedWidget - lib/screens/authenticated/pin_protected/contact_verification.dart', {
      'contactId': contactId,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final hasLoaded = ref.watch(_contactLoadedProvider(contactId));
    final isLoadingFlag = ref.watch(_contactLoadingProvider(contactId));
    final contactState = ref.watch(contactNotifierProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _scheduleContactLoading(context, ref, contactState, hasLoaded, isLoadingFlag);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contact_verification.title', fallback: 'Verification'),
        backRoutePath: RoutePaths.home,
        showSettings: false,
        onBeforeBack: () async {
          await ref.read(confirmsConfirmProvider.notifier).confirmsDelete(contactsId: contactId);
        },
        onBeforeHome: () async {
          await ref.read(confirmsConfirmProvider.notifier).confirmsDelete(contactsId: contactId);
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: contactState.when(
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
        ),
      ),
    );
  }

  void _scheduleContactLoading(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Contact?> contactState,
    bool hasLoaded,
    bool isLoadingFlag,
  ) {
    final isInProviderState = contactState.hasValue && contactState.value?.contactId == contactId;
    final isAlreadyLoaded = hasLoaded || isInProviderState;
    log('_scheduleContactLoading - lib/screens/authenticated/pin_protected/contact_verification.dart', {
      'contactId': contactId,
      'hasLoadedFlag': hasLoaded,
      'isInProviderState': isInProviderState,
      'isAlreadyLoaded': isAlreadyLoaded,
      'isLoadingFlag': isLoadingFlag,
      'contactStateHasValue': contactState.hasValue,
      'contactStateHasError': contactState.hasError,
    });
    if (isAlreadyLoaded || isLoadingFlag) {
      log('Skipping new load request - lib/screens/authenticated/pin_protected/contact_verification.dart', {
        'contactId': contactId,
        'reason': isAlreadyLoaded ? 'already_loaded' : 'already_loading',
      });
      return;
    }
    final future = _loadContactData(context, ref);
    future.whenComplete(() {
      log('Contact loading future completed - lib/screens/authenticated/pin_protected/contact_verification.dart', {
        'contactId': contactId,
      });
    });
  }

  Future<void> _loadContactData(BuildContext context, WidgetRef ref) async {
    log('_loadContactData start - lib/screens/authenticated/pin_protected/contact_verification.dart', {
      'contactId': contactId,
    });
    final notifier = ref.read(contactNotifierProvider.notifier);
    final loadingNotifier = ref.read(_contactLoadingProvider(contactId).notifier);
    final loadedNotifier = ref.read(_contactLoadedProvider(contactId).notifier);
    loadingNotifier.state = true;
    loadedNotifier.state = false;
    try {
      final exists = await notifier.checkContactExists(contactId);
      log('checkContactExists completed - lib/screens/authenticated/pin_protected/contact_verification.dart', {
        'contactId': contactId,
        'exists': exists,
      });
      if (!exists) {
        loadingNotifier.state = false;
        loadedNotifier.state = false;
        if (context.mounted) {
          context.go(RoutePaths.home);
        }
        return;
      }
      await notifier.loadContact(contactId);
      notifier.markAsVisited(contactId);
      loadingNotifier.state = false;
      loadedNotifier.state = true;
      log('_loadContactData success - lib/screens/authenticated/pin_protected/contact_verification.dart', {
        'contactId': contactId,
      });
    } catch (error, stackTrace) {
      log('_loadContactData error - lib/screens/authenticated/pin_protected/contact_verification.dart', {
        'contactId': contactId,
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
      loadingNotifier.state = false;
      loadedNotifier.state = false;
    }
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
                            radius: AppDimensionsTheme.getProfileImageRadius(context),
                            backgroundColor: Colors.grey[300],
                            backgroundImage: contact.profileImage.isNotEmpty ? NetworkImage(contact.profileImage) : null,
                            child: contact.profileImage.isEmpty ? Icon(Icons.person, size: AppDimensionsTheme.getProfileImageRadius(context) * 0.56) : null,
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

                    Text(
                      contact.firstName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: AppDimensionsTheme.isSmallScreen(context) ? 22.4 : 28, // 20% smaller on small screens
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A3751),
                        decoration: TextDecoration.none,
                        height: AppDimensionsTheme.isSmallScreen(context) ? 25.6 / 22.4 : 32 / 28, // line-height proportionally adjusted
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      contact.lastName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: AppDimensionsTheme.isSmallScreen(context) ? 22.4 : 28, // 20% smaller on small screens
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A3751),
                        decoration: TextDecoration.none,
                        height: AppDimensionsTheme.isSmallScreen(context) ? 25.6 / 22.4 : 32 / 28, // line-height proportionally adjusted
                      ),
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
                    // ignore: dead_code
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
                      log('Star icon tapped - lib/screens/authenticated/pin_protected/contact_verification.dart', {
                        'contactId': contactId,
                      });
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
                            style: const TextStyle(
                              color: Color(0xFF014459),
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
                              context.go(RoutePaths.home);
                            } else if (context.mounted) {
                              _trackContactAction(ref, 'delete_failed');
                              CustomSnackBar.show(
                                context: context,
                                text: I18nService().t('screen_contact_verification.delete_failed', fallback: 'Failed to delete contact'),
                                variant: CustomSnackBarVariant.error,
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
                                style: const TextStyle(
                                  color: Color(0xFF014459),
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
