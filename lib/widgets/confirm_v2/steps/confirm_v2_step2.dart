import '../../../exports.dart';

class ConfirmV2Step2 extends ConsumerWidget {
  final ConfirmPayload confirmPayload;
  final Function(ConfirmV2Step, {ConfirmPayload? newPayload, String? error}) onStepChange;

  const ConfirmV2Step2({
    super.key,
    required this.confirmPayload,
    required this.onStepChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lyt til confirms_realtime updates
    final realtimeData = ref.watch(confirmsRealtimeNotifierProvider(confirmPayload.confirmsId));

    return realtimeData.when(
      data: (data) {
        // Check hvis status er ændret til 3
        if (data != null && data.status == 3) {
          // Trigger step change til step 3
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onStepChange(ConfirmV2Step.step3);
          });
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'Venter',
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

            // Debug info
            if (data != null) ...[
              Gap(AppDimensionsTheme.getMedium(context)),
              CustomText(
                text: 'Status: ${data.status}',
                type: CustomTextType.info400,
                alignment: CustomTextAlignment.center,
              ),
              CustomText(
                text: 'Confirms ID: ${data.confirmsId}',
                type: CustomTextType.info400,
                alignment: CustomTextAlignment.center,
              ),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Indlæser realtime data...'),
          ],
        ),
      ),
      error: (error, stack) {
        // Trigger error step change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onStepChange(ConfirmV2Step.step1, error: 'Realtime fejl: $error');
        });

        return Center(
          child: CustomText(
            text: 'Fejl ved realtime: $error',
            type: CustomTextType.bread,
            alignment: CustomTextAlignment.center,
          ),
        );
      },
    );
  }
}

// Created on 2025-01-27 at 13:55:00
