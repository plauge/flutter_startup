import '../../exports.dart';
import 'package:flutter/services.dart';
import '../modals/phone_code_confirmation_modal.dart';

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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'No Phone Number',
                  style: AppTheme.getHeadingMedium(context),
                ),
                content: Text(
                  'This contact has not registered a phone number. Please ask them to add their phone number to their profile before you can make a phone call.',
                  style: AppTheme.getBodyMedium(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
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
        }
        return;
      }

      // Continue with phone code creation if contact has phone number
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Contact has phone number, proceeding with phone code creation');
      await _createPhoneCode();
    } catch (error, stackTrace) {
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Error checking phone number status: $error');
      log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Stack trace: $stackTrace');
      _trackEvent('actions_holder_phone_check_error', {'error': error.toString()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to verify phone number. Please try again.',
              style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createPhoneCode() async {
    try {
      final phoneCodeCreateNotifier = ref.read(phoneCodeCreateNotifierProvider.notifier);

      // Call the detailed method to get the actual response data
      final response = await phoneCodeCreateNotifier.createPhoneCodeDetailed(widget.contactId);

      if (response != null && response.statusCode == 200) {
        log('✅ [widgets/confirm_v2/actions_holder.dart] Phone code created successfully');
        log('[widgets/confirm_v2/actions_holder.dart] Phone codes ID: ${response.data.payload.phoneCodesId}');
        log('[widgets/confirm_v2/actions_holder.dart] Confirm code: ${response.data.payload.confirmCode}');
        _trackEvent('actions_holder_phone_success', {});

        if (mounted) {
          // Show the modal with phone code data
          showPhoneCodeConfirmationModal(
            context,
            response.data.payload.confirmCode,
            response.data.payload.phoneCodesId,
            response.data.payload.contactId,
          );
        }
      } else {
        log('❌ [widgets/confirm_v2/actions_holder.dart] Phone code creation failed');
        _trackEvent('actions_holder_phone_failed', {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                I18nService().t(
                  'widget_actions_holder.phone_code_failed',
                  fallback: 'Failed to create phone code',
                ),
                style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('❌ [widgets/confirm_v2/actions_holder.dart] Exception in phone code creation: $e');
      _trackEvent('actions_holder_phone_exception', {'exception': e.toString()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              I18nService().t(
                'widget_actions_holder.phone_code_exception',
                fallback: 'Exception occurred while creating phone code',
              ),
              style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleTextAction() async {
    log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text action triggered for contact: ${widget.contactId}');
    _trackEvent('actions_holder_text_clicked', {});

    try {
      final textCodeCreateNotifier = ref.read(textCodeCreateNotifierProvider.notifier);

      // Call the detailed method to get the actual response data
      final response = await textCodeCreateNotifier.createTextCodeDetailed(widget.contactId);

      if (response != null && response.statusCode == 200) {
        log('✅ [widgets/confirm_v2/actions_holder.dart] Text code created successfully');
        log('[widgets/confirm_v2/actions_holder.dart] Text codes ID: ${response.data.payload.textCodesId}');
        log('[widgets/confirm_v2/actions_holder.dart] Confirm code: ${response.data.payload.confirmCode}');
        _trackEvent('actions_holder_text_success', {});

        // Copy code to clipboard immediately
        await Clipboard.setData(ClipboardData(text: response.data.payload.confirmCode));

        if (mounted) {
          // Show the modal with code
          TextCodeConfirmationModal.show(context, response.data.payload.confirmCode);
        }
      } else {
        log('❌ [widgets/confirm_v2/actions_holder.dart] Text code creation failed');
        _trackEvent('actions_holder_text_failed', {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'An error occurred. Please try again.',
                style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('❌ [widgets/confirm_v2/actions_holder.dart] Exception in text action: $e');
      _trackEvent('actions_holder_text_exception', {'exception': e.toString()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred. Please try again.',
              style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Track widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent('actions_holder_initialized', {});
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Phone Action Button
          GestureDetector(
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
                      fallback: 'Phone',
                    ),
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

          // Text Action Button
          GestureDetector(
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
                      fallback: 'Text',
                    ),
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
    );
  }
}

// Created: 2025-01-16 18:00:00
