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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactNotifierProvider);

    return contactState.when(
      data: (contact) => _buildStep2Content(context, contact),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: CustomText(
          text: 'Fejl ved indlæsning af kontakt: $error',
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
          text: 'Kontakt ikke fundet',
          type: CustomTextType.bread,
          alignment: CustomTextAlignment.center,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: 'Afventer',
          buttonType: CustomButtonType.secondary,
          onPressed: _handleNextPressed,
          enabled: false,
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        CustomText(
          text: '${contact.firstName} mangler at bekræfte, vent et øjeblik.',
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
