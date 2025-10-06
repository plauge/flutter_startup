import '../../exports.dart';
import 'package:flutter/services.dart';

class PhoneCodeConfirmationModal extends StatelessWidget {
  final String confirmCode;
  final String phoneCodesId;
  final String contactId;

  const PhoneCodeConfirmationModal({
    super.key,
    required this.confirmCode,
    required this.phoneCodesId,
    required this.contactId,
  });

  static void show(BuildContext context, String confirmCode, String phoneCodesId, String contactId) {
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

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'phone_code_confirmation_modal',
      'contact_id': contactId,
      'phone_codes_id': phoneCodesId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _cancelPhoneCode(WidgetRef ref) async {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/phone_code_confirmation_modal.dart][_cancelPhoneCode] Cancelling phone code: $phoneCodesId');

    _trackEvent(ref, 'phone_code_confirmation_modal_cancelled', {
      'phone_codes_id': phoneCodesId,
    });

    try {
      final cancelNotifier = ref.read(phoneCodesCancelNotifierProvider.notifier);
      await cancelNotifier.cancelPhoneCode(phoneCodesId);

      log('✅ [widgets/modals/phone_code_confirmation_modal.dart] Phone code cancelled successfully');
      _trackEvent(ref, 'phone_code_confirmation_modal_cancel_success', {});
    } catch (e) {
      log('❌ [widgets/modals/phone_code_confirmation_modal.dart] Failed to cancel phone code: $e');
      _trackEvent(ref, 'phone_code_confirmation_modal_cancel_failed', {'error': e.toString()});
    }
  }

  void _copyCodeToClipboard(BuildContext context, String code, WidgetRef ref) {
    Clipboard.setData(ClipboardData(text: code));

    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/phone_code_confirmation_modal.dart][_copyCodeToClipboard] Phone code copied to clipboard: $code');

    _trackEvent(ref, 'phone_code_confirmation_modal_code_copied', {
      'code_length': code.length,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          I18nService().t(
            'widget_phone_code_confirmation_modal.code_copied',
            fallback: 'Phone code copied to clipboard',
          ),
          style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
                        fallback: 'Phone Code',
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

                // Phone code display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF014459),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        I18nService().t(
                          'widget_phone_code_confirmation_modal.use_this_code',
                          fallback: 'Use this phone code:',
                        ),
                        style: AppTheme.getBodyMedium(context).copyWith(
                          color: const Color(0xFF014459),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF014459)),
                        ),
                        child: Text(
                          confirmCode,
                          style: AppTheme.getHeadingMedium(context).copyWith(
                            color: const Color(0xFF014459),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(AppDimensionsTheme.getMedium(context)),

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
                        phoneCodesId,
                      ),
                      Gap(AppDimensionsTheme.getSmall(context)),
                      _buildInfoRow(
                        context,
                        I18nService().t(
                          'widget_phone_code_confirmation_modal.contact_id',
                          fallback: 'Contact ID:',
                        ),
                        contactId,
                      ),
                    ],
                  ),
                ),

                Gap(AppDimensionsTheme.getLarge(context)),

                // Copy button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('phone_code_confirmation_modal_copy_button'),
                    onPressed: () => _copyCodeToClipboard(context, confirmCode, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF014459),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      I18nService().t(
                        'widget_phone_code_confirmation_modal.copy_code',
                        fallback: 'Copy Phone Code',
                      ),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Gap(AppDimensionsTheme.getMedium(context)),

                // Cancel button
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
                        fallback: 'Cancel Phone Code',
                      ),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

// Created: 2025-01-16 19:15:00
