import '../../exports.dart';
import '../../providers/contact_provider.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCodeConfirmationModal extends ConsumerStatefulWidget {
  final String confirmCode;
  final String phoneCodesId;
  final String contactId;

  const PhoneCodeConfirmationModal({
    super.key,
    required this.confirmCode,
    required this.phoneCodesId,
    required this.contactId,
  });

  @override
  ConsumerState<PhoneCodeConfirmationModal> createState() => _PhoneCodeConfirmationModalState();
}

class _PhoneCodeConfirmationModalState extends ConsumerState<PhoneCodeConfirmationModal> {
  static final log = scopedLogger(LogCategory.gui);

  StreamSubscription<List<UserNotificationRealtime>>? _notificationSubscription;
  List<UserNotificationRealtime> _notifications = [];
  bool _hasCalledPhone = false;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    log('[widgets/modals/phone_code_confirmation_modal.dart][initState] Modal initialized - phoneCodesId: ${widget.phoneCodesId}, contactId: ${widget.contactId}, confirmCode: ${widget.confirmCode}');
    _startListeningToNotifications();
    // Start med 45 sekunder timer når modalen starter i Waiting tilstand
    // Dette sikrer at modalen forbliver åben i 45 sekunder når Call-actionen kommer
    _startAutoCloseTimer(duration: const Duration(seconds: 45));
  }

  @override
  void dispose() {
    log('[widgets/modals/phone_code_confirmation_modal.dart][dispose] Disposing modal - phoneCodesId: ${widget.phoneCodesId}');
    _autoCloseTimer?.cancel();
    log('[widgets/modals/phone_code_confirmation_modal.dart][dispose] Auto-close timer cancelled');
    if (_notificationSubscription != null) {
      log('[widgets/modals/phone_code_confirmation_modal.dart][dispose] Cancelling notification subscription');
      _notificationSubscription?.cancel();
      log('[widgets/modals/phone_code_confirmation_modal.dart][dispose] Notification subscription cancelled');
    } else {
      log('[widgets/modals/phone_code_confirmation_modal.dart][dispose] No active notification subscription to cancel');
    }
    super.dispose();
  }

  void _startAutoCloseTimer({Duration duration = const Duration(seconds: 10)}) {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_startAutoCloseTimer] Starting auto-close timer (${duration.inSeconds} seconds)');
    _autoCloseTimer = Timer(duration, () {
      log('[widgets/modals/phone_code_confirmation_modal.dart][_startAutoCloseTimer] Auto-close timer expired, closing modal');
      if (mounted) {
        _closeModal();
      } else {
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startAutoCloseTimer] Widget not mounted, skipping auto-close');
      }
    });
  }

  Future<void> _closeModal() async {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_closeModal] Closing modal - phoneCodesId: ${widget.phoneCodesId}');
    _autoCloseTimer?.cancel();
    final context = this.context;
    if (context.mounted) {
      await _cancelPhoneCode(ref);
      if (context.mounted) {
        Navigator.of(context).pop();
        log('[widgets/modals/phone_code_confirmation_modal.dart][_closeModal] Modal closed successfully');
      }
    }
  }

  void _startListeningToNotifications() {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Starting to listen for notifications with phone_codes_id: ${widget.phoneCodesId}');

    // Use Future.microtask to delay provider calls until after widget tree is built
    Future.microtask(() async {
      log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Inside Future.microtask');

      try {
        final notifier = ref.read(userNotificationRealtimeNotifierProvider.notifier);
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Notifier obtained');

        // Load initial notifications
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Loading initial notifications...');
        await notifier.loadUserNotifications(widget.phoneCodesId);
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Initial notifications loaded');

        // Start listening to realtime updates
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Starting to watch notifications...');
        _notificationSubscription = notifier.watchUserNotifications(widget.phoneCodesId).listen(
          (notifications) {
            log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Received ${notifications.length} notifications');
            for (final notification in notifications) {
              log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Notification detail: action=${notification.action}, encrypted_phone_number=present');
            }

            if (mounted) {
              log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Widget mounted, updating state');
              // Gem værdien før setState, så vi kan bruge den i _handleCallAction
              final wasInWaiting = _notifications.isEmpty;
              log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] wasInWaiting: $wasInWaiting, current notifications count: ${_notifications.length}, new notifications count: ${notifications.length}');
              setState(() {
                _notifications = notifications;
              });
              log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] State updated with ${notifications.length} notifications');

              // Hvis status ændrer sig til -1 eller 1, skift timer'en til 10 sekunder
              if (notifications.isNotEmpty && (notifications.first.action == 1 || notifications.first.action == -1)) {
                log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Status changed to ${notifications.first.action}, switching timer to 10 seconds');
                _autoCloseTimer?.cancel();
                _startAutoCloseTimer(duration: const Duration(seconds: 10));
              }

              // Hvis action = 1 og vi ikke allerede har ringet, dekrypter og ring
              if (notifications.isNotEmpty && notifications.first.action == 1 && !_hasCalledPhone) {
                log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Action=1 detected and phone not called yet, triggering call action with wasInWaiting=$wasInWaiting');
                // Send wasInWaiting til _handleCallAction så den kan bruge den korrekte værdi
                _handleCallAction(notifications.first, wasInWaiting: wasInWaiting);
              } else {
                log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Call action not triggered - isEmpty: ${notifications.isEmpty}, hasCalledPhone: $_hasCalledPhone, action: ${notifications.isNotEmpty ? notifications.first.action : "N/A"}');
              }
            } else {
              log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Widget not mounted, skipping state update');
            }
          },
          onError: (error, stackTrace) {
            log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Error: $error');
            log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Stack trace: $stackTrace');
          },
        );
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Notification subscription established');
      } catch (e, stackTrace) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Exception during setup: $e');
        log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Stack trace: $stackTrace');
      }
    });
  }

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'phone_code_confirmation_modal',
      'contact_id': widget.contactId,
      'phone_codes_id': widget.phoneCodesId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  bool _hasActionNotifications() {
    final hasActions = _notifications.any((notification) => notification.action == 1 || notification.action == -1 || notification.action == -10);
    log('[widgets/modals/phone_code_confirmation_modal.dart][_hasActionNotifications] Checking for action notifications: $hasActions (total notifications: ${_notifications.length})');
    return hasActions;
  }

  Future<void> _cancelPhoneCode(WidgetRef ref) async {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Cancelling phone code: ${widget.phoneCodesId}');

    _trackEvent(ref, 'phone_code_confirmation_modal_cancelled', {
      'phone_codes_id': widget.phoneCodesId,
    });

    try {
      log('[widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Obtaining cancel notifier...');
      final cancelNotifier = ref.read(phoneCodesCancelNotifierProvider.notifier);
      log('[widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Calling cancelPhoneCode API...');
      await cancelNotifier.cancelPhoneCode(widget.phoneCodesId);

      log('✅ [widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Phone code cancelled successfully');
      _trackEvent(ref, 'phone_code_confirmation_modal_cancel_success', {});
    } catch (e, stackTrace) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Failed to cancel phone call: $e');
      log('[widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Stack trace: $stackTrace');
      _trackEvent(ref, 'phone_code_confirmation_modal_cancel_failed', {'error': e.toString()});
    }
  }

  // Platform-specifik metode til at åbne dialeren med pre-filled nummer
  Future<bool> _dialPhoneNumber(String phoneNumber) async {
    final telUrl = 'tel:$phoneNumber';
    final uri = Uri.parse(telUrl);

    if (Platform.isAndroid) {
      // Prøv først platform channel på Android for at sikre nummeret bliver pre-filled
      const platform = MethodChannel('eu.idtruster.app/phone');
      try {
        log('[widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Android: Trying platform channel with phoneNumber: (length: ${phoneNumber.length})');
        final bool result = await platform.invokeMethod('dialPhoneNumber', {'phoneNumber': phoneNumber});
        log('[widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Platform channel returned: $result');
        return result;
      } on PlatformException catch (e) {
        log('⚠️ [widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Platform channel error: ${e.message}');
        log('[widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Falling back to url_launcher...');
      } on MissingPluginException catch (e) {
        log('⚠️ [widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Platform channel not implemented: ${e.message}');
        log('[widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Falling back to url_launcher...');
      }

      // Fallback til url_launcher på Android hvis platform channel fejler
      try {
        log('[widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Android fallback: Using url_launcher with: $telUrl');
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] Android url_launcher error: $e');
        return false;
      }
    } else {
      // Brug url_launcher på iOS hvor det virker perfekt
      log('[widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] iOS: Using url_launcher with: $telUrl');
      try {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_dialPhoneNumber] iOS launch error: $e');
        return false;
      }
    }
  }

  Future<void> _handleCallAction(UserNotificationRealtime notification, {bool wasInWaiting = false}) async {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Starting call action - phoneCodesId: ${widget.phoneCodesId}, wasInWaiting: $wasInWaiting');

    try {
      // Marker at vi har håndteret opkaldet
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Marking _hasCalledPhone as true');
      _hasCalledPhone = true;

      // Hent contact for at finde modpartens userId
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Loading contact for contactId: ${widget.contactId}');
      final contact = await ref.read(supabaseServiceContactProvider).loadContactLight(widget.contactId);
      if (contact == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke hente contact for contactId: ${widget.contactId}');
        return;
      }
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Contact loaded successfully');

      // Find modpartens userId via contact
      final currentUserId = ref.read(authProvider)?.id;
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Current userId: $currentUserId');
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Contact initiatorUserId: ${contact.initiatorUserId}, receiverUserId: ${contact.receiverUserId}');

      final otherUserId = contact.initiatorUserId == currentUserId ? contact.receiverUserId : contact.initiatorUserId;

      if (otherUserId == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke finde modpartens userId');
        return;
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Other userId determined: $otherUserId');

      // Dekrypter telefonnummeret med modpartens userId
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Starting phone number decryption...');
      final phoneNumber = await _decryptPhoneNumber(ref, notification.encryptedPhoneNumber, otherUserId);

      if (phoneNumber.startsWith('Error:')) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke dekryptere telefonnummer: $phoneNumber');
        return;
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Telefonnummer dekrypteret succesfuldt (length: ${phoneNumber.length})');

      // Ring til telefonnummeret med platform-specifik implementation
      // Android: Bruger ACTION_DIAL intent via platform channel for at sikre pre-fill
      // iOS: Bruger url_launcher som virker perfekt
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Launching phone app with platform-specific method...');
      final success = await _dialPhoneNumber(phoneNumber);

      if (success) {
        log('✅ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Telefon-app åbnet succesfuldt');
        _trackEvent(ref, 'phone_code_confirmation_modal_call_initiated', {
          'phone_number_length': phoneNumber.length,
        });
      } else {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke åbne telefon-app');
        _trackEvent(ref, 'phone_code_confirmation_modal_call_failed', {});
      }
    } catch (e, stackTrace) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Fejl ved opkald: $e');
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Stack trace: $stackTrace');
      _trackEvent(ref, 'phone_code_confirmation_modal_call_error', {'error': e.toString()});
    }
  }

  Future<String> _decryptPhoneNumberWithOtherUserId(WidgetRef ref, String encryptedPhoneNumber) async {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Starting decryption with other userId lookup');

    try {
      // Hent contact for at finde modpartens userId
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Loading contact...');
      final contact = await ref.read(supabaseServiceContactProvider).loadContactLight(widget.contactId);
      if (contact == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Could not load contact');
        return 'Error: Could not load contact';
      }

      // Find modpartens userId via contact
      final currentUserId = ref.read(authProvider)?.id;
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Current userId: $currentUserId');
      final otherUserId = contact.initiatorUserId == currentUserId ? contact.receiverUserId : contact.initiatorUserId;

      if (otherUserId == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Could not find other user ID');
        return 'Error: Could not find other user ID';
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Other userId found: $otherUserId, calling _decryptPhoneNumber');
      return _decryptPhoneNumber(ref, encryptedPhoneNumber, otherUserId);
    } catch (e, stackTrace) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Exception: $e');
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumberWithOtherUserId] Stack trace: $stackTrace');
      return 'Error: $e';
    }
  }

  Future<String> _decryptPhoneNumber(WidgetRef ref, String encryptedPhoneNumber, String customerUserId) async {
    log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Starting decryption for contact: ${widget.contactId}, customerUserId: $customerUserId');

    try {
      // Hent brugerens token
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Getting current user token...');
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (token == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Token er null');
        return 'Error: Token not found';
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Token hentet succesfuldt (length: ${token.length})');

      // Hent den krypterede fælles nøgle via provideren med customerUserId
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Getting encrypted key from provider for userId: $customerUserId');
      final contactEncryptedKey = await ref.read(contactGetMyEncryptedKeyProvider(customerUserId).future);

      if (contactEncryptedKey == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Kunne ikke hente krypteret fælles nøgle via provider for userId: $customerUserId');
        return 'Error: Encrypted key not found';
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Krypteret fælles nøgle hentet succesfuldt (length: ${contactEncryptedKey.length})');

      // Dekrypter den fælles nøgle med token
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Decrypting common key with token...');
      final commonKey = await AESGCMEncryptionUtils.decryptString(contactEncryptedKey, token);

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Fælles nøgle dekrypteret succesfuldt (length: ${commonKey.length})');

      // Dekrypter telefonnummeret med den fælles nøgle
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Decrypting phone number with common key...');
      final decryptedPhoneNumber = await AESGCMEncryptionUtils.decryptString(encryptedPhoneNumber, commonKey);

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Telefonnummer dekrypteret succesfuldt (length: ${decryptedPhoneNumber.length})');

      return decryptedPhoneNumber;
    } catch (e, stackTrace) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Fejl ved dekryptering: $e');
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Stack trace: $stackTrace');
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[widgets/modals/phone_code_confirmation_modal.dart][build] Building PhoneCodeConfirmationModal - phoneCodesId: ${widget.phoneCodesId}, notification count: ${_notifications.length}');

    return Consumer(
      builder: (context, ref, child) {
        // Track modal view
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _trackEvent(ref, 'phone_code_confirmation_modal_viewed', {});
        });

        final modalContent = Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      I18nService().t(
                        'widget_phone_code_confirmation_modal.title',
                        fallback: 'Phone Call',
                      ),
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    GestureDetector(
                      key: const Key('phone_code_confirmation_modal_close_button'),
                      onTap: () async {
                        await _closeModal();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF014459),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                Gap(AppDimensionsTheme.getLarge(context)),

                // Debug info - ændr true til false for at skjule
                // ignore: dead_code
                if (false) ...[
                  // Additional data display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            Gap(AppDimensionsTheme.getSmall(context)),
                            Text(
                              I18nService().t(
                                'widget_phone_code_confirmation_modal.additional_info',
                                fallback: 'Additional Information:',
                              ),
                              style: AppTheme.getBodyMedium(context).copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Gap(AppDimensionsTheme.getSmall(context)),
                        _buildInfoRow(
                          context,
                          I18nService().t(
                            'widget_phone_code_confirmation_modal.phone_codes_id',
                            fallback: 'Phone Codes ID:',
                          ),
                          widget.phoneCodesId,
                        ),
                        Gap(AppDimensionsTheme.getSmall(context)),
                        _buildInfoRow(
                          context,
                          I18nService().t(
                            'widget_phone_code_confirmation_modal.contact_id',
                            fallback: 'Contact ID:',
                          ),
                          widget.contactId,
                        ),
                        // Display realtime notification data
                        if (_notifications.isNotEmpty) ...[
                          Gap(AppDimensionsTheme.getSmall(context)),
                          Text(
                            I18nService().t(
                              'widget_phone_code_confirmation_modal.realtime_data',
                              fallback: 'Realtime Data:',
                            ),
                            style: AppTheme.getBodyMedium(context).copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Gap(AppDimensionsTheme.getSmall(context)),
                          for (final notification in _notifications) ...[
                            _buildInfoRow(
                              context,
                              I18nService().t(
                                'widget_phone_code_confirmation_modal.action',
                                fallback: 'Action:',
                              ),
                              notification.action.toString(),
                            ),
                            Gap(AppDimensionsTheme.getSmall(context)),
                            FutureBuilder<String>(
                              future: _decryptPhoneNumberWithOtherUserId(ref, notification.encryptedPhoneNumber),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return _buildInfoRow(
                                    context,
                                    I18nService().t(
                                      'widget_phone_code_confirmation_modal.phone_number',
                                      fallback: 'Phone Number:',
                                    ),
                                    I18nService().t(
                                      'widget_phone_code_confirmation_modal.decrypting',
                                      fallback: 'Decrypting...',
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return _buildInfoRow(
                                    context,
                                    I18nService().t(
                                      'widget_phone_code_confirmation_modal.phone_number',
                                      fallback: 'Phone Number:',
                                    ),
                                    'Error: ${snapshot.error}',
                                  );
                                }

                                return _buildInfoRow(
                                  context,
                                  I18nService().t(
                                    'widget_phone_code_confirmation_modal.phone_number',
                                    fallback: 'Phone Number:',
                                  ),
                                  snapshot.data ??
                                      I18nService().t(
                                        'widget_phone_code_confirmation_modal.not_available',
                                        fallback: 'N/A',
                                      ),
                                );
                              },
                            ),
                            Gap(AppDimensionsTheme.getSmall(context)),
                            // Display action status text
                            _buildActionStatusText(context, notification.action),
                            Gap(AppDimensionsTheme.getSmall(context)),
                          ],
                        ],
                      ],
                    ),
                  ),

                  Gap(AppDimensionsTheme.getLarge(context)),
                ],

                // Her - Status boks
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Center(
                    child: _notifications.isEmpty
                        ? Text(
                            I18nService().t(
                              'widget_phone_code_confirmation_modal.waiting',
                              fallback: 'Waiting',
                            ),
                            style: AppTheme.getBodyMedium(context).copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          )
                        : _buildStatusText(context, _notifications.first.action),
                  ),
                ),

                Gap(AppDimensionsTheme.getLarge(context)),

                // Cancel button - only show if no notifications with actions
                if (!_hasActionNotifications()) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('phone_code_confirmation_modal_cancel_button'),
                      onPressed: () async {
                        await _closeModal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        I18nService().t(
                          'widget_phone_code_confirmation_modal.cancel_button',
                          fallback: 'Cancel',
                        ),
                        style: AppTheme.getBodyMedium(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        // Wrap in SafeArea on Android to avoid navigation buttons overlap
        return Platform.isAndroid ? SafeArea(top: false, child: modalContent) : modalContent;
      },
    );
  }

  Widget _buildStatusText(BuildContext context, int action) {
    String statusText;

    switch (action) {
      case 1:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_call',
          fallback: 'Call',
        );
        break;
      case -1:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_dont_call',
          fallback: "Don't call",
        );
        break;
      case -10:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_timeout',
          fallback: 'Timeout',
        );
        break;
      default:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_unknown',
          fallback: 'Unknown',
        );
        break;
    }

    return Text(
      statusText,
      style: AppTheme.getBodyMedium(context).copyWith(
        color: Colors.blue[700],
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildActionStatusText(BuildContext context, int action) {
    String statusText;
    Color textColor;

    switch (action) {
      case 1:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_call',
          fallback: 'Call',
        );
        textColor = Colors.green[700]!;
        break;
      case -1:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_call_rejected',
          fallback: 'Call rejected',
        );
        textColor = Colors.red[700]!;
        break;
      case -10:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_timeout',
          fallback: 'Timeout',
        );
        textColor = Colors.orange[700]!;
        break;
      default:
        statusText = I18nService().t(
          'widget_phone_code_confirmation_modal.action_unknown',
          fallback: 'Unknown action: $action',
        );
        textColor = Colors.grey[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: AppTheme.getBodyMedium(context).copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.getBodyMedium(context).copyWith(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SelectableText(
            value,
            style: AppTheme.getBodyMedium(context).copyWith(
              color: Colors.blue[800],
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

void showPhoneCodeConfirmationModal(BuildContext context, String confirmCode, String phoneCodesId, String contactId) {
  final log = scopedLogger(LogCategory.gui);
  log('[widgets/modals/phone_code_confirmation_modal.dart][showPhoneCodeConfirmationModal] Showing modal - phoneCodesId: $phoneCodesId, contactId: $contactId, confirmCode: $confirmCode');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      log('[widgets/modals/phone_code_confirmation_modal.dart][showPhoneCodeConfirmationModal] Building modal content');
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          log('[widgets/modals/phone_code_confirmation_modal.dart][showPhoneCodeConfirmationModal] onPopInvokedWithResult - didPop: $didPop');
          if (didPop) {
            log('[widgets/modals/phone_code_confirmation_modal.dart][showPhoneCodeConfirmationModal] Modal is being closed, cancelling phone code: $phoneCodesId');
            // Modal is being closed, cancel the phone code
            final container = ProviderScope.containerOf(context);
            final cancelNotifier = container.read(phoneCodesCancelNotifierProvider.notifier);
            await cancelNotifier.cancelPhoneCode(phoneCodesId);
            log('[widgets/modals/phone_code_confirmation_modal.dart][showPhoneCodeConfirmationModal] Phone code cancelled successfully');
          }
        },
        child: PhoneCodeConfirmationModal(
          confirmCode: confirmCode,
          phoneCodesId: phoneCodesId,
          contactId: contactId,
        ),
      );
    },
  );
  log('[widgets/modals/phone_code_confirmation_modal.dart][showPhoneCodeConfirmationModal] Modal display triggered');
}

// Created: 2025-01-16 19:15:00
