import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';

class StepWatchWidget extends StatelessWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const StepWatchWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step Watch',
          style: AppTheme.getBodyLarge(context),
        ),
      ],
    );
  }
}
