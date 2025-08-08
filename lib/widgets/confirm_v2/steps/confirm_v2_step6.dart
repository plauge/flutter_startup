import '../../../exports.dart';
import '../../../providers/contact_provider.dart';
import '../confirm_payload_test_data_widget.dart';

class ConfirmV2Step6 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final Future<String> comparisonResult;

  const ConfirmV2Step6({
    super.key,
    required this.confirmPayload,
    required this.onNext,
    required this.onReset,
    required this.comparisonResult,
  });

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'confirm_v2_step6',
      'confirms_id': confirmPayload.confirmsId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track step view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent(ref, 'confirm_v2_step6_viewed', {});
    });

    final contactState = ref.watch(contactNotifierProvider);

    return contactState.when(
      data: (contact) => _buildContent(context, contact),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: CustomText(
          text: I18nService().t(
            'widget_confirm_v2_step6.error_loading_contact',
            fallback: 'Error while loading contact: $error',
            variables: {'error': error.toString()},
          ),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Contact? contact) {
    if (contact == null) {
      return Center(
        child: CustomText(
          text: I18nService().t('widget_confirm_v2_step6.contact_not_found', fallback: 'Contact not found'),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // CustomText(
        //   text: 'Step 6',
        //   type: CustomTextType.head,
        //   alignment: CustomTextAlignment.center,
        // ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        FutureBuilder<String>(
          future: comparisonResult,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: const CircularProgressIndicator(),
              );
            }

            final result = snapshot.data ?? 'ERROR';

            // Track result once when it's available - using Consumer to get ref
            return Consumer(
              builder: (context, ref, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _trackEvent(ref, 'confirm_v2_step6_result', {
                    'result': result,
                  });
                });

                return Column(
                  children: [
                    CustomCodeValidation(
                      content: result == 'ERROR' ? I18nService().t('widget_confirm_v2_step6.failed', fallback: 'Failed') : I18nService().t('widget_confirm_v2_step6.confirmed', fallback: 'Confirmed'),
                      state: result == 'ERROR' ? ValidationState.invalid : ValidationState.valid,
                    ),
                    Gap(AppDimensionsTheme.getLarge(context)),
                    CustomHelpText(
                      text: result == 'ERROR'
                          ? I18nService().t(
                              'widget_confirm_v2_step6.failed_to_confirm',
                              fallback: 'Failed to confirm identity with ${contact.firstName}. Please try again.',
                              variables: {'firstName': contact.firstName},
                            )
                          : I18nService().t(
                              'widget_confirm_v2_step6.confirmed_text',
                              fallback: 'You and ${contact.firstName} have now confirmed each other\'s identity',
                              variables: {'firstName': contact.firstName},
                            ),
                      type: CustomTextType.bread,
                      alignment: CustomTextAlignment.center,
                    ),
                  ],
                );
              },
            );
          },
        ),

        // Gap(AppDimensionsTheme.getLarge(context)),
        // ConfirmPayloadTestDataWidget(
        //   confirmPayload: confirmPayload,
        // ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        // CustomButton(
        //   text: 'Næste',
        //   onPressed: _handleNextPressed,
        // ),
        // Gap(AppDimensionsTheme.getMedium(context)),
        // CustomButton(
        //   text: 'Reset',
        //   onPressed: _handleResetPressed,
        // ),
      ],
    );
  }

  void _handleNextPressed() {
    onNext();
  }

  void _handleResetPressed() {
    onReset();
  }
}

// Created on 2025-01-27 at 16:38:00
