import '../../../exports.dart';
import '../confirm_payload_test_data_widget.dart';

class ConfirmV2Step5 extends ConsumerStatefulWidget {
  final ConfirmPayload confirmPayload;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final Future<void> Function() onAutoProcess;

  const ConfirmV2Step5({
    super.key,
    required this.confirmPayload,
    required this.onNext,
    required this.onReset,
    required this.onAutoProcess,
  });

  @override
  ConsumerState<ConfirmV2Step5> createState() => _ConfirmV2Step5State();
}

class _ConfirmV2Step5State extends ConsumerState<ConfirmV2Step5> {
  static final log = scopedLogger(LogCategory.gui);

  void _trackEvent(WidgetRef ref, String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'confirm_v2_step5',
      'confirms_id': widget.confirmPayload.confirmsId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void initState() {
    super.initState();
    log('[confirm_v2_step5.dart][initState] Step 5 loading, calling auto process');

    // Kald auto-process når widget loader
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent(ref, 'confirm_v2_step5_viewed', {});
      widget.onAutoProcess();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // CustomText(
        //   text: 'Step 5',
        //   type: CustomTextType.head,
        //   alignment: CustomTextAlignment.center,
        // ),
        // Gap(AppDimensionsTheme.getLarge(context)),
        // ConfirmPayloadTestDataWidget(
        //   confirmPayload: widget.confirmPayload,
        // ),
      ],
    );
  }

  void _handleNextPressed() {
    widget.onNext();
  }

  void _handleResetPressed() {
    widget.onReset();
  }
}

// Created on 2025-01-27 at 16:38:00
