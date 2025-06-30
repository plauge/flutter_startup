import '../../../exports.dart';
import '../confirm_payload_test_data_widget.dart';

class ConfirmV2Step3 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onNext;
  final VoidCallback onReset;

  const ConfirmV2Step3({
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
          text: 'Bekræftelse fuldført! 3',
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        ConfirmPayloadTestDataWidget(
          confirmPayload: confirmPayload,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: 'Næste',
          onPressed: _handleNextPressed,
        ),
        Gap(AppDimensionsTheme.getMedium(context)),
        CustomButton(
          text: 'Reset',
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

// Created on 2025-01-27 at 13:55:00
