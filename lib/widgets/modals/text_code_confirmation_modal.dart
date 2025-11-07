import '../../exports.dart';
import 'package:flutter/services.dart';

class TextCodeConfirmationModal extends StatelessWidget {
  final String confirmCode;

  const TextCodeConfirmationModal({
    super.key,
    required this.confirmCode,
  });

  static void show(BuildContext context, String confirmCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TextCodeConfirmationModal(confirmCode: confirmCode),
    );
  }

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'text_code_confirmation_modal',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _copyCodeToClipboard(BuildContext context, String code, WidgetRef ref) {
    Clipboard.setData(ClipboardData(text: code));

    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/text_code_confirmation_modal.dart][_copyCodeToClipboard] Code copied to clipboard: $code');

    _trackEvent(ref, 'text_code_confirmation_modal_code_copied', {
      'code_length': code.length,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          I18nService().t(
            'widget_text_code_confirmation_modal.code_copied',
            fallback: 'Code copied to clipboard',
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
          _trackEvent(ref, 'text_code_confirmation_modal_viewed', {});
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
                        'widget_text_code_confirmation_modal.title',
                        fallback: 'Tracking Code',
                      ),
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    GestureDetector(
                      onTap: () {
                        _trackEvent(ref, 'text_code_confirmation_modal_closed', {});
                        Navigator.of(context).pop();
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

                // Code display with automatic copy
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
                          'widget_text_code_confirmation_modal.use_this_code',
                          fallback: 'Use this code:',
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

                Gap(AppDimensionsTheme.getLarge(context)),

                // Confirmation message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          I18nService().t(
                            'widget_text_code_confirmation_modal.code_in_clipboard',
                            fallback: 'The code is now in your clipboard.',
                          ),
                          style: AppTheme.getBodyMedium(context).copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(AppDimensionsTheme.getLarge(context)),

                // Copy button (for manual copy if needed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('text_code_confirmation_modal_copy_button'),
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
                        'widget_text_code_confirmation_modal.copy_code_again',
                        fallback: 'Copy Code Again',
                      ),
                      style: AppTheme.getBodyMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
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
}

// Created: 2025-01-16 18:35:00
