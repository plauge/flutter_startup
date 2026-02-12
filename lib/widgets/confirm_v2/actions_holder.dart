import '../../exports.dart';
import 'package:flutter/services.dart';
import '../modals/phone_code_confirmation_modal.dart';
import '../modals/handshake_confirmation_modal.dart';

class ActionsHolder extends ConsumerStatefulWidget {
  final String contactId;

  const ActionsHolder({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<ActionsHolder> createState() => _ActionsHolderState();
}

class _ActionsHolderState extends ConsumerState<ActionsHolder> {
  static final log = scopedLogger(LogCategory.gui);

  @override
  void initState() {
    super.initState();
    log('[widgets/confirm_v2/actions_holder.dart][initState] ActionsHolder initialized for contact: ${widget.contactId}');
  }

  @override
  void dispose() {
    log('[widgets/confirm_v2/actions_holder.dart][dispose] ActionsHolder disposing for contact: ${widget.contactId}');
    super.dispose();
  }

  void _trackEvent(String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'actions_holder',
      'contact_id': widget.contactId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _handlePhoneAction() async {
    log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Phone action triggered for contact: ${widget.contactId}');
    _trackEvent('actions_holder_phone_clicked', {});

    try {
      // Check if contact has a phone number registered
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Checking if contact has phone number...');
      final hasPhoneNumber = await ref.read(doContactsHavePhoneNumberProvider(widget.contactId).future);

      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Phone number check result: $hasPhoneNumber');

      if (hasPhoneNumber == false || hasPhoneNumber == null) {
        log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Contact does not have a phone number registered');
        _trackEvent('actions_holder_phone_no_number', {});

        if (mounted) {
          log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Showing no phone number dialog');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  I18nService().t(
                    'widget_actions_holder.no_phone_number_title',
                    fallback: 'No Phone Number',
                  ),
                  style: AppTheme.getHeadingMedium(context),
                ),
                content: Text(
                  I18nService().t(
                    'widget_actions_holder.no_phone_number_message',
                    fallback: 'This contact has not registered a phone number. Please ask them to add their phone number to their profile before you can make a phone call.',
                  ),
                  style: AppTheme.getBodyMedium(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      I18nService().t(
                        'widget_actions_holder.ok_button',
                        fallback: 'OK',
                      ),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: const Color(0xFF014459),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] No phone number dialog shown');
        } else {
          log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Widget not mounted, skipping dialog');
        }
        log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Returning early - no phone number');
        return;
      }

      // Continue with phone code creation if contact has phone number
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Contact has phone number, proceeding with phone code creation');
      await _createPhoneCode();
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Phone action completed successfully');
    } catch (error, stackTrace) {
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Error checking phone number status: $error');
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Stack trace: $stackTrace');
      _trackEvent('actions_holder_phone_check_error', {'error': error.toString()});

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          text: I18nService().t(
            'widget_actions_holder.verify_error',
            fallback: 'Unable to verify phone number. Please try again.',
          ),
          variant: CustomSnackBarVariant.error,
        );
      }
    }
  }

  Future<void> _createPhoneCode() async {
    log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Starting phone code creation for contact: ${widget.contactId}');

    try {
      final phoneCodeCreateNotifier = ref.read(phoneCodeCreateNotifierProvider.notifier);
      log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Phone code notifier obtained');

      // Call the detailed method to get the actual response data
      log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Calling createPhoneCodeDetailed API...');
      final response = await phoneCodeCreateNotifier.createPhoneCodeDetailed(widget.contactId);
      log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] API call completed');

      if (response != null && response.statusCode == 200) {
        log('✅ [widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Phone code created successfully');
        log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Response status code: ${response.statusCode}');
        log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Phone codes ID: ${response.data.payload.phoneCodesId}');
        log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Confirm code: ${response.data.payload.confirmCode}');
        log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Contact ID from response: ${response.data.payload.contactId}');
        _trackEvent('actions_holder_phone_success', {});

        if (mounted) {
          log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Widget is mounted, showing modal');
          // Show the modal with phone code data
          showPhoneCodeConfirmationModal(
            context,
            response.data.payload.confirmCode,
            response.data.payload.phoneCodesId,
            response.data.payload.contactId,
          );
          log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Modal shown successfully');
        } else {
          log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Widget not mounted, skipping modal');
        }
      } else {
        log('❌ [widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Phone code creation failed');
        log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Response: ${response != null ? "status ${response.statusCode}" : "null response"}');
        _trackEvent('actions_holder_phone_failed', {});

        if (mounted) {
          log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Showing error snackbar');
          CustomSnackBar.show(
            context: context,
            text: I18nService().t(
              'widget_actions_holder.phone_code_failed',
              fallback: 'Failed to create phone code',
            ),
            variant: CustomSnackBarVariant.error,
          );
        } else {
          log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Widget not mounted, skipping error snackbar');
        }
      }
    } catch (e, stackTrace) {
      log('❌ [widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Exception in phone code creation: $e');
      log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Stack trace: $stackTrace');
      _trackEvent('actions_holder_phone_exception', {'exception': e.toString()});

      if (mounted) {
        log('[widgets/confirm_v2/actions_holder.dart][_createPhoneCode] Showing exception snackbar');
        CustomSnackBar.show(
          context: context,
          text: I18nService().t(
            'widget_actions_holder.phone_code_exception',
            fallback: 'Exception occurred while creating phone code',
          ),
          variant: CustomSnackBarVariant.error,
        );
      }
    }
  }

  Future<void> _handleHandshakeAction() async {
    log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Handshake action triggered for contact: ${widget.contactId}');
    _trackEvent('actions_holder_handshake_clicked', {});

    if (mounted) {
      log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Widget is mounted, showing modal');
      await HandshakeConfirmationModal.show(context, widget.contactId);
      log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Modal closed');

      // Call confirmsDelete when modal is closed
      try {
        log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Calling confirmsDelete after modal close');
        await ref.read(confirmsConfirmProvider.notifier).confirmsDelete(contactsId: widget.contactId);
        log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] confirmsDelete completed successfully');
      } catch (e, stackTrace) {
        log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Error calling confirmsDelete: $e');
        log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Stack trace: $stackTrace');
      }
    } else {
      log('[widgets/confirm_v2/actions_holder.dart][_handleHandshakeAction] Widget not mounted, skipping modal');
    }
  }

  Future<void> _handleTextAction() async {
    log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text action triggered for contact: ${widget.contactId}');
    _trackEvent('actions_holder_text_clicked', {});

    try {
      final textCodeCreateNotifier = ref.read(textCodeCreateNotifierProvider.notifier);
      log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text code notifier obtained');

      // Call the detailed method to get the actual response data
      log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Calling createTextCodeDetailed API...');
      final response = await textCodeCreateNotifier.createTextCodeDetailed(widget.contactId);
      log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] API call completed');

      if (response != null && response.statusCode == 200) {
        log('✅ [widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text code created successfully');
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Response status code: ${response.statusCode}');
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text codes ID: ${response.data.payload.textCodesId}');
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Confirm code: ${response.data.payload.confirmCode}');
        _trackEvent('actions_holder_text_success', {});

        // Copy code to clipboard immediately
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Copying code to clipboard...');
        await Clipboard.setData(ClipboardData(text: 'ID-Truster: ${response.data.payload.confirmCode}'));
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Code copied to clipboard successfully');

        if (mounted) {
          log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Widget is mounted, showing modal');
          // Show the modal with code
          TextCodeConfirmationModal.show(context, response.data.payload.confirmCode);
          log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Modal shown successfully');
        } else {
          log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Widget not mounted, skipping modal');
        }
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text action completed successfully');
      } else {
        log('❌ [widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text code creation failed');
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Response: ${response != null ? "status ${response.statusCode}" : "null response"}');
        _trackEvent('actions_holder_text_failed', {});

        if (mounted) {
          log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Showing error snackbar');
          CustomSnackBar.show(
            context: context,
            text: I18nService().t(
              'widget_actions_holder.error_occurred',
              fallback: 'An error occurred. Please try again.',
            ),
            variant: CustomSnackBarVariant.error,
          );
        } else {
          log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Widget not mounted, skipping error snackbar');
        }
      }
    } catch (e, stackTrace) {
      log('❌ [widgets/confirm_v2/actions_holder.dart][_handleTextAction] Exception in text action: $e');
      log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Stack trace: $stackTrace');
      _trackEvent('actions_holder_text_exception', {'exception': e.toString()});

      if (mounted) {
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Showing exception snackbar');
        CustomSnackBar.show(
          context: context,
          text: I18nService().t(
            'widget_actions_holder.error_occurred',
            fallback: 'An error occurred. Please try again.',
          ),
          variant: CustomSnackBarVariant.error,
        );
      } else {
        log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Widget not mounted, skipping exception snackbar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[widgets/confirm_v2/actions_holder.dart][build] Building ActionsHolder for contact: ${widget.contactId}');

    // Track widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent('actions_holder_initialized', {});
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Row(
        children: [
          // Phone Action Button
          Expanded(
            child: GestureDetector(
              key: const Key('actions_holder_phone_button'),
              onTap: _handlePhoneAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone,
                      color: const Color(0xFF014459),
                      size: 32,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    Text(
                      I18nService().t(
                        'widget_actions_holder.phone_label',
                        fallback: 'Call',
                      ),
                      style: TextStyle(
                        color: const Color(0xFF014459),
                        fontFamily: 'Poppins',
                        fontSize: AppDimensionsTheme.isSmallScreen(context) ? 9.6 : 12, // 20% smaller on small screens
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Gap(6),

          // Text Action Button
          Expanded(
            child: GestureDetector(
              key: const Key('actions_holder_text_button'),
              onTap: _handleTextAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.message,
                      color: const Color(0xFF014459),
                      size: 32,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    Text(
                      I18nService().t(
                        'widget_actions_holder.text_label',
                        fallback: 'Code',
                      ),
                      style: TextStyle(
                        color: const Color(0xFF014459),
                        fontFamily: 'Poppins',
                        fontSize: AppDimensionsTheme.isSmallScreen(context) ? 9.6 : 12, // 20% smaller on small screens
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Gap(6),

          // Handshake Action Button
          Expanded(
            child: GestureDetector(
              key: const Key('actions_holder_handshake_button'),
              onTap: _handleHandshakeAction,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.handshake,
                      color: const Color(0xFF014459),
                      size: 32,
                    ),
                    Gap(AppDimensionsTheme.getSmall(context)),
                    Text(
                      I18nService().t(
                        'widget_actions_holder.handshake_label',
                        fallback: 'Handshake',
                      ),
                      style: TextStyle(
                        color: const Color(0xFF014459),
                        fontFamily: 'Poppins',
                        fontSize: AppDimensionsTheme.isSmallScreen(context) ? 9.6 : 12, // 20% smaller on small screens
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Created: 2025-01-16 18:00:00
