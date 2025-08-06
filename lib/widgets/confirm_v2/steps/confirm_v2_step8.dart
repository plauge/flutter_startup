import '../../../exports.dart';
import '../confirm_payload_test_data_widget.dart';

class ConfirmV2Step8 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onNext;
  final VoidCallback onReset;

  const ConfirmV2Step8({
    super.key,
    required this.confirmPayload,
    required this.onNext,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: I18nService().t('widget_confirm_v2_step8.title', fallback: 'Step 8'),
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        ConfirmPayloadTestDataWidget(
          confirmPayload: confirmPayload,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: I18nService().t('widget_confirm_v2_step8.finish_button', fallback: 'Finish'),
          onPressed: _handleNextPressed,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        CustomButton(
          text: I18nService().t('widget_confirm_v2_step8.reset_button', fallback: 'Reset'),
          onPressed: _handleResetPressed,
        ),
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
