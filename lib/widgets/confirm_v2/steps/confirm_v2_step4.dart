import '../../../exports.dart';
import '../confirm_payload_test_data_widget.dart';

class ConfirmV2Step4 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onReset;

  const ConfirmV2Step4({
    super.key,
    required this.confirmPayload,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Step 4',
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        ConfirmPayloadTestDataWidget(
          confirmPayload: confirmPayload,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: 'Reset',
          onPressed: _handleResetPressed,
        ),
      ],
    );
  }

  void _handleResetPressed() {
    onReset();
  }
}

// Created on 2025-01-27 at 16:38:00
