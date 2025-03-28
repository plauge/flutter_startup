import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/confirm_state.dart';
import '../confirm.dart';

class ConfirmErrorWidget extends StatelessWidget {
  final String errorMessage;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const ConfirmErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Der opstod en fejl',
          style: AppTheme.getBodyLarge(context).copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage,
          style: AppTheme.getBodyMedium(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => onStateChange(ConfirmState.initial, null),
          style: AppTheme.getPrimaryButtonStyle(context),
          child: const Text('Prøv igen'),
        ),
      ],
    );
  }
}
