import '../../exports.dart';
import 'dart:async';

class PhoneCallConfirmationModal extends ConsumerStatefulWidget {
  const PhoneCallConfirmationModal({
    super.key,
  });

  static void show(BuildContext context) {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/phone_call_confirmation_modal.dart][show] Showing modal');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const PhoneCallConfirmationModal(),
    );
  }

  @override
  ConsumerState<PhoneCallConfirmationModal> createState() => _PhoneCallConfirmationModalState();
}

class _PhoneCallConfirmationModalState extends ConsumerState<PhoneCallConfirmationModal> {
  static final log = scopedLogger(LogCategory.gui);
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    log('[widgets/modals/phone_call_confirmation_modal.dart][initState] Modal initialized');
    _startAutoCloseTimer();
  }

  @override
  void dispose() {
    log('[widgets/modals/phone_call_confirmation_modal.dart][dispose] Disposing modal');
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  void _startAutoCloseTimer() {
    log('[widgets/modals/phone_call_confirmation_modal.dart][_startAutoCloseTimer] Starting auto-close timer (10 seconds)');
    _autoCloseTimer = Timer(const Duration(seconds: 10), () {
      log('[widgets/modals/phone_call_confirmation_modal.dart][_startAutoCloseTimer] Auto-close timer expired, closing modal');
      if (mounted) {
        Navigator.of(context).pop();
        log('[widgets/modals/phone_call_confirmation_modal.dart][_startAutoCloseTimer] Modal closed successfully');
      } else {
        log('[widgets/modals/phone_call_confirmation_modal.dart][_startAutoCloseTimer] Widget not mounted, skipping auto-close');
      }
    });
  }

  void _closeModal() {
    log('[widgets/modals/phone_call_confirmation_modal.dart][_closeModal] Closing modal');
    _autoCloseTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
      log('[widgets/modals/phone_call_confirmation_modal.dart][_closeModal] Modal closed successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('[widgets/modals/phone_call_confirmation_modal.dart][build] Building PhoneCallConfirmationModal');

    return Consumer(
      builder: (context, ref, child) {
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
                        'widget_phone_call_confirmation_modal.title',
                        fallback: 'Phone Call',
                      ),
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    GestureDetector(
                      key: const Key('phone_call_confirmation_modal_close_button'),
                      onTap: _closeModal,
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
                // Message content
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 48,
                        color: const Color(0xFF0E5D4A),
                      ),
                      Gap(AppDimensionsTheme.getMedium(context)),
                      Text(
                        I18nService().t(
                          'widget_phone_call_confirmation_modal.message',
                          fallback: 'You will now be called.',
                        ),
                        textAlign: TextAlign.center,
                        style: AppTheme.getBodyMedium(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF014459),
                        ),
                      ),
                    ],
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

// Created: 2025-01-29 17:00:00

