import '../../../exports.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildStep2Content(context);
  }

  Widget _buildStep2Content(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Venter 2',
          type: CustomTextType.head,
          alignment: CustomTextAlignment.center,
        ),

        Gap(AppDimensionsTheme.getLarge(context)),

        const CircularProgressIndicator(),

        Gap(AppDimensionsTheme.getLarge(context)),

        CustomText(
          text: 'Venter på realtime opdatering...',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),

        Gap(AppDimensionsTheme.getMedium(context)),
        CustomText(
          text: 'Confirms ID: ${confirmPayload.confirmsId}',
          type: CustomTextType.info400,
          alignment: CustomTextAlignment.center,
        ),

        // Manuel navigation knapper
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomButton(
          text: 'Næste (manuel)',
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
