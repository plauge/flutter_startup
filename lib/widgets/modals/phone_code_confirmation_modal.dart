import '../../exports.dart';
import '../../providers/contact_provider.dart';
import 'dart:async';
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
  StreamSubscription<List<UserNotificationRealtime>>? _notificationSubscription;
  List<UserNotificationRealtime> _notifications = [];
  bool _hasCalledPhone = false;

  @override
  void initState() {
    super.initState();
    _startListeningToNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToNotifications() {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Starting to listen for notifications with phone_codes_id: ${widget.phoneCodesId}');

    // Use Future.microtask to delay provider calls until after widget tree is built
    Future.microtask(() async {
      final notifier = ref.read(userNotificationRealtimeNotifierProvider.notifier);

      // Load initial notifications
      await notifier.loadUserNotifications(widget.phoneCodesId);

      // Start listening to realtime updates
      _notificationSubscription = notifier.watchUserNotifications(widget.phoneCodesId).listen(
        (notifications) {
          log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Received ${notifications.length} notifications');
          for (final notification in notifications) {
            log('[widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Notification: action=${notification.action}, encrypted_phone_number=${notification.encryptedPhoneNumber}');
          }
          if (mounted) {
            setState(() {
              _notifications = notifications;
            });

            // Hvis action = 1 og vi ikke allerede har ringet, dekrypter og ring
            if (notifications.isNotEmpty && notifications.first.action == 1 && !_hasCalledPhone) {
              _handleCallAction(notifications.first);
            }
          }
        },
        onError: (error) {
          log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_startListeningToNotifications] Error: $error');
        },
      );
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
    return _notifications.any((notification) => notification.action == 1 || notification.action == -1 || notification.action == -10);
  }

  Future<void> _cancelPhoneCode(WidgetRef ref) async {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Cancelling phone code: ${widget.phoneCodesId}');

    _trackEvent(ref, 'phone_code_confirmation_modal_cancelled', {
      'phone_codes_id': widget.phoneCodesId,
    });

    try {
      final cancelNotifier = ref.read(phoneCodesCancelNotifierProvider.notifier);
      await cancelNotifier.cancelPhoneCode(widget.phoneCodesId);

      log('✅ [widgets/modals/phone_code_confirmation_modal.dart] Phone code cancelled successfully');
      _trackEvent(ref, 'phone_code_confirmation_modal_cancel_success', {});
    } catch (e) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart] Failed to cancel phone code: $e');
      _trackEvent(ref, 'phone_code_confirmation_modal_cancel_failed', {'error': e.toString()});
    }
  }

  Future<void> _handleCallAction(UserNotificationRealtime notification) async {
    final log = scopedLogger(LogCategory.gui);

    try {
      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Starting call action');

      // Marker at vi har håndteret opkaldet
      _hasCalledPhone = true;

      // Hent contact for at finde modpartens userId
      final contact = await ref.read(supabaseServiceContactProvider).loadContactLight(widget.contactId);
      if (contact == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke hente contact');
        return;
      }

      // Find modpartens userId via contact
      final currentUserId = ref.read(authProvider)?.id;
      final otherUserId = contact.initiatorUserId == currentUserId ? contact.receiverUserId : contact.initiatorUserId;

      if (otherUserId == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke finde modpartens userId');
        return;
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Current userId: $currentUserId, Other userId: $otherUserId');

      // Dekrypter telefonnummeret med modpartens userId
      final phoneNumber = await _decryptPhoneNumber(ref, notification.encryptedPhoneNumber, otherUserId);

      if (phoneNumber.startsWith('Error:')) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke dekryptere telefonnummer: $phoneNumber');
        return;
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Dekrypteret telefonnummer: $phoneNumber');

      // Ring til telefonnummeret
      final uri = Uri.parse('tel:$phoneNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('✅ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Telefon-app åbnet succesfuldt');

        _trackEvent(ref, 'phone_code_confirmation_modal_call_initiated', {
          'phone_number_length': phoneNumber.length,
        });
      } else {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Kunne ikke åbne telefon-app');
        _trackEvent(ref, 'phone_code_confirmation_modal_call_failed', {});
      }
    } catch (e) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_handleCallAction] Fejl ved opkald: $e');
      _trackEvent(ref, 'phone_code_confirmation_modal_call_error', {'error': e.toString()});
    }
  }

  Future<String> _decryptPhoneNumberWithOtherUserId(WidgetRef ref, String encryptedPhoneNumber) async {
    try {
      // Hent contact for at finde modpartens userId
      final contact = await ref.read(supabaseServiceContactProvider).loadContactLight(widget.contactId);
      if (contact == null) {
        return 'Error: Could not load contact';
      }

      // Find modpartens userId via contact
      final currentUserId = ref.read(authProvider)?.id;
      final otherUserId = contact.initiatorUserId == currentUserId ? contact.receiverUserId : contact.initiatorUserId;

      if (otherUserId == null) {
        return 'Error: Could not find other user ID';
      }

      return _decryptPhoneNumber(ref, encryptedPhoneNumber, otherUserId);
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> _decryptPhoneNumber(WidgetRef ref, String encryptedPhoneNumber, String customerUserId) async {
    final log = scopedLogger(LogCategory.gui);

    try {
      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Starting decryption for contact: ${widget.contactId}, customerUserId: $customerUserId');

      // Hent brugerens token
      final token = await ref.read(storageProvider.notifier).getCurrentUserToken();

      if (token == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Token er null');
        return 'Error: Token not found';
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Token hentet succesfuldt');

      // Hent den krypterede fælles nøgle via provideren med customerUserId
      final contactEncryptedKey = await ref.read(contactGetMyEncryptedKeyProvider(customerUserId).future);

      if (contactEncryptedKey == null) {
        log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Kunne ikke hente krypteret fælles nøgle via provider for userId: $customerUserId');
        return 'Error: Encrypted key not found';
      }

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Krypteret fælles nøgle hentet succesfuldt fra provider for userId: $customerUserId');

      // Dekrypter den fælles nøgle med token
      final commonKey = await AESGCMEncryptionUtils.decryptString(contactEncryptedKey, token);

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Fælles nøgle dekrypteret succesfuldt');

      // Dekrypter telefonnummeret med den fælles nøgle
      final decryptedPhoneNumber = await AESGCMEncryptionUtils.decryptString(encryptedPhoneNumber, commonKey);

      log('[widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Telefonnummer dekrypteret succesfuldt: $decryptedPhoneNumber');

      return decryptedPhoneNumber;
    } catch (e) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart][_decryptPhoneNumber] Fejl ved dekryptering: $e');
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Track modal view
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _trackEvent(ref, 'phone_code_confirmation_modal_viewed', {});
        });

        return Container(
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
                      style: AppTheme.getHeadingLarge(context),
                    ),
                    GestureDetector(
                      key: const Key('phone_code_confirmation_modal_close_button'),
                      onTap: () async {
                        await _cancelPhoneCode(ref);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
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
                                    'Decrypting...',
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
                                  snapshot.data ?? 'N/A',
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
                            'Waiting',
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
                        await _cancelPhoneCode(ref);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText(BuildContext context, int action) {
    String statusText;

    switch (action) {
      case 1:
        statusText = 'Call';
        break;
      case -1:
        statusText = "Don't call";
        break;
      case -10:
        statusText = 'Timeout';
        break;
      default:
        statusText = 'Unknown';
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Modal is being closed, cancel the phone code
          final container = ProviderScope.containerOf(context);
          final cancelNotifier = container.read(phoneCodesCancelNotifierProvider.notifier);
          await cancelNotifier.cancelPhoneCode(phoneCodesId);
        }
      },
      child: PhoneCodeConfirmationModal(
        confirmCode: confirmCode,
        phoneCodesId: phoneCodesId,
        contactId: contactId,
      ),
    ),
  );
}

// Created: 2025-01-16 19:15:00
