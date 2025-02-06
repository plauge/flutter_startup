import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/confirms_provider.dart';
import 'confirm.dart';

class InitiatorWidget extends ConsumerWidget {
  final String contactId;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const InitiatorWidget({
    super.key,
    required this.contactId,
    required this.onStateChange,
  });

  void _handleConfirm(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: contactId,
            question: "test",
          );

      debugPrint('Initial result: $result');

      // Sikrer at vi har et Map
      if (result is! Map<String, dynamic>) {
        throw Exception('Unexpected response format: $result');
      }

      // Fra loggen kan vi se at new_record er direkte på result objektet
      final isNewRecord = result['new_record'];
      debugPrint('Is new record: $isNewRecord');

      if (isNewRecord is! bool) {
        throw Exception('new_record is not a boolean: $isNewRecord');
      }

      // Send raw data videre og lad hver widget håndtere det
      if (isNewRecord) {
        onStateChange(ConfirmState.newConfirm, result);
      } else {
        onStateChange(ConfirmState.existingConfirm, result);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _handleConfirm: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Error',
              style:
                  AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
            ),
            content: Text(
              'An error occurred: $e',
              style: AppTheme.getBodyMedium(context),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Swipe to confirm connection',
          style: AppTheme.getBodyMedium(context),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _handleConfirm(context, ref),
          style: AppTheme.getPrimaryButtonStyle(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_forward),
              SizedBox(width: 8),
              Text('Swipe To Confirm'),
            ],
          ),
        ),
      ],
    );
  }
}
