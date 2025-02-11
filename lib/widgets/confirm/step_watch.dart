import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../providers/confirms_provider.dart';

class StepWatchWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const StepWatchWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  ConsumerState<StepWatchWidget> createState() => _StepWatchWidgetState();
}

class _StepWatchWidgetState extends ConsumerState<StepWatchWidget> {
  @override
  void initState() {
    super.initState();
    final confirmsId = widget.rawData['confirms_id'] as String?;
    if (confirmsId != null) {
      Future(() {
        ref.read(confirmsWatchProvider.notifier).watch(confirmsId: confirmsId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchData = ref.watch(confirmsWatchProvider);

    // Reagér på watchData og kald onStateChange
    watchData.whenData((data) {
      if (data != null) {
        // Kald parent widget's onStateChange med den nye data
        widget.onStateChange(
          // Her kan du bestemme hvilken state der skal bruges baseret på data
          data['status'] == 2 ? ConfirmState.step_3 : ConfirmState.watch,
          {
            'data': {'payload': data}
          },
        );
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step Watch',
          style: AppTheme.getBodyLarge(context),
        ),
        const SizedBox(height: 16),
        watchData.when(
          data: (data) => Text(
            'Watch Data: ${data.toString()}',
            style: AppTheme.getBodyMedium(context),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text(
            'Error: $error',
            style: AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
