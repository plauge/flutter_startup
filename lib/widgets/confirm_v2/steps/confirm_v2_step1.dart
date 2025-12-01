import '../../../exports.dart';
import '../../../providers/contact_provider.dart';

class ConfirmV2Step1 extends ConsumerWidget {
  final String contactsId;
  final VoidCallback onStartConfirm;
  final String? errorMessage;

  const ConfirmV2Step1({
    super.key,
    required this.contactsId,
    required this.onStartConfirm,
    this.errorMessage,
  });

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'confirm_v2_step1',
      'contacts_id': contactsId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track step view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent(ref, 'confirm_v2_step1_viewed', {});
    });

    final contactState = ref.watch(contactNotifierProvider);

    return contactState.when(
      data: (contact) => _buildContent(context, ref, contact),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: CustomText(
          text: I18nService().t(
            'widget_confirm_v2_step1.error_loading_contact',
            fallback: 'Error while loading contact: $error',
            variables: {'error': error.toString()},
          ),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Contact? contact) {
    if (contact == null) {
      return Center(
        child: CustomText(
          text: I18nService().t('widget_confirm_v2_step1.contact_not_found', fallback: 'Contact not found'),
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
        //   text: 'Bekræft kontakt',
        //   type: CustomTextType.head,
        //   alignment: CustomTextAlignment.center,
        // ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: I18nService().t('widget_confirm_v2_step1.confirm_button', fallback: 'Yes, it is me'),
          onPressed: () => _handleConfirmPressed(ref),
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: I18nService().t(
            'widget_confirm_v2_step1.confirm_text',
            fallback: 'Press the button to make a digital handshake with \$firstName',
            variables: {'firstName': contact.firstName},
          ),
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),

        if (errorMessage != null) ...[
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: errorMessage!,
            type: CustomTextType.bread,
            alignment: CustomTextAlignment.center,
          ),
        ],
      ],
    );
  }

  void _handleConfirmPressed(WidgetRef ref) {
    _trackEvent(ref, 'confirm_v2_step1_confirm_pressed', {});
    onStartConfirm();
  }
}

// Created on 2025-01-27 at 13:55:00
