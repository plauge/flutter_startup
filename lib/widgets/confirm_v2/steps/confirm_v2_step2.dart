import '../../../exports.dart';
import '../../../providers/contact_provider.dart';

class ConfirmV2Step2 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final Function(ConfirmV2Step, {ConfirmPayload? newPayload, String? error}) onStepChange;

  const ConfirmV2Step2({
    super.key,
    required this.confirmPayload,
    required this.onNext,
    required this.onReset,
    required this.onStepChange,
  });

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'confirm_v2_step2',
      'confirms_id': confirmPayload.confirmsId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track step view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent(ref, 'confirm_v2_step2_viewed', {
        'new_record': confirmPayload.newRecord,
      });
    });

    final contactState = ref.watch(contactNotifierProvider);

    return contactState.when(
      data: (contact) => _buildStep2Content(context, contact),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: CustomText(
          text: I18nService().t(
            'widget_confirm_v2_step2.error_loading_contact',
            fallback: 'Error while loading contact: $error',
            variables: {'error': error.toString()},
          ),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      ),
    );
  }

  Widget _buildStep2Content(BuildContext context, Contact? contact) {
    if (contact == null) {
      return Center(
        child: CustomText(
          text: I18nService().t('widget_confirm_v2_step2.contact_not_found', fallback: 'Contact not found'),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCodeValidation(
          content: I18nService().t('widget_confirm_v2_step2.waiting', fallback: 'Waiting'),
          state: ValidationState.waiting,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t(
            'widget_confirm_v2_step2.waiting_text',
            fallback: '${contact.firstName} is waiting to confirm, please wait a moment.',
            variables: {'firstName': contact.firstName},
          ),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
        // CustomText(
        //   text: 'Venter 2',
        //   type: CustomTextType.head,
        //   alignment: CustomTextAlignment.center,
        // ),

        // Gap(AppDimensionsTheme.getLarge(context)),

        // const CircularProgressIndicator(),

        // Gap(AppDimensionsTheme.getLarge(context)),

        // CustomText(
        //   text: 'Venter på realtime opdatering...',
        //   type: CustomTextType.bread,
        //   alignment: CustomTextAlignment.center,
        // ),

        // Gap(AppDimensionsTheme.getMedium(context)),
        // CustomText(
        //   text: 'Confirms ID: ${confirmPayload.confirmsId}',
        //   type: CustomTextType.info400,
        //   alignment: CustomTextAlignment.center,
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

// Created on 2025-01-27 at 13:55:00
