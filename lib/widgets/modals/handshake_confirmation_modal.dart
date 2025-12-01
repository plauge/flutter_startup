import '../../exports.dart';
import 'dart:io' show Platform;
import '../confirm_v2/confirm_v2.dart';

class HandshakeConfirmationModal extends StatelessWidget {
  final String contactId;

  const HandshakeConfirmationModal({
    super.key,
    required this.contactId,
  });

  static Future<void> show(BuildContext context, String contactId) {
    final log = scopedLogger(LogCategory.gui);
    log('[widgets/modals/handshake_confirmation_modal.dart][show] Showing Handshake modal for contact: $contactId');

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => HandshakeConfirmationModal(contactId: contactId),
    ).then((_) {
      log('[widgets/modals/handshake_confirmation_modal.dart][show] Modal closed for contact: $contactId');
    });
  }

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'handshake_confirmation_modal',
      'contact_id': contactId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // Track modal view
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _trackEvent(ref, 'handshake_confirmation_modal_viewed', {});
        });

        final screenHeight = MediaQuery.of(context).size.height;
        final modalHeight = screenHeight * 0.3;

        final modalContent = Container(
          height: modalHeight,
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
                        'widget_handshake_confirmation_modal.title',
                        fallback: 'Handshake',
                      ),
                      style: AppTheme.getHeadingMedium(context),
                    ),
                    GestureDetector(
                      key: const Key('handshake_confirmation_modal_close_button'),
                      onTap: () {
                        _trackEvent(ref, 'handshake_confirmation_modal_closed', {});
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

                // ConfirmV2 widget wrapped in Expanded for scrolling
                Expanded(
                  child: SingleChildScrollView(
                    child: ConfirmV2(
                      contactsId: contactId,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        // Wrap in SafeArea on Android to avoid navigation buttons overlap
        return Platform.isAndroid ? SafeArea(top: false, child: modalContent) : modalContent;
      },
    );
  }
}

// Created: 2025-01-27 12:00:00

