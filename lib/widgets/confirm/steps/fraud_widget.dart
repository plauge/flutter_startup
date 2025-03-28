import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/confirm_state.dart';
import 'dart:developer';

/// Widget til at vise svindel-advarsel
class FraudWidget extends StatelessWidget {
  /// Rådata for bekræftelsen
  final Map<String, dynamic> rawData;

  /// Callback til at håndtere tilstandsændringer
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  /// Opretter en ny FraudWidget
  const FraudWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    // Log svindel-forsøget
    log('Svindel-forsøg opdaget: ${rawData['confirms_id']}',
        name: 'FraudWidget');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Svindel-forsøg opdaget',
          style: AppTheme.getBodyLarge(context).copyWith(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Der er opdaget et muligt svindel-forsøg. Bekræftelsen er blevet afbrudt af sikkerhedsmæssige årsager.',
          style: AppTheme.getBodyMedium(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => onStateChange(ConfirmState.initial, null),
          style: AppTheme.getPrimaryButtonStyle(context),
          child: const Text('Gå tilbage'),
        ),
      ],
    );
  }
}
