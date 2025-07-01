import '../../../exports.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            final result = snapshot.data ?? 'FEJL';
            return Container(
              padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
              decoration: BoxDecoration(
                color: result == 'OK' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result == 'OK' ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: CustomText(
                text: result,
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
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
