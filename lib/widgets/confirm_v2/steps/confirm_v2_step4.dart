import '../../../exports.dart';
import '../confirm_payload_test_data_widget.dart';

class ConfirmV2Step4 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onNext;
  final VoidCallback onReset;

  const ConfirmV2Step4({
    super.key,
    required this.confirmPayload,
    required this.onNext,
    required this.onReset,
  });

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'confirm_v2_step4',
      'confirms_id': confirmPayload.confirmsId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track step view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent(ref, 'confirm_v2_step4_viewed', {});
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // CustomText(
        //   text: 'Step 4',
        //   type: CustomTextType.head,
        //   alignment: CustomTextAlignment.center,
        // ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        // ConfirmPayloadTestDataWidget(
        //   confirmPayload: confirmPayload,
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
