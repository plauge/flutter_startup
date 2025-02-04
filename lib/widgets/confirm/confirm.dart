import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/confirms_provider.dart';

class Confirm extends ConsumerWidget {
  final String contactId;

  const Confirm({
    super.key,
    required this.contactId,
  });

  void _handleConfirm(BuildContext context, WidgetRef ref) async {
    try {
      print('Starting confirm in widget...');
      final result = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: contactId,
            question: "test",
          );

      print('Widget received result: $result');
      print('Result type: ${result.runtimeType}');
      print('Result keys: ${result.keys.toList()}');

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Confirm Success',
              style: AppTheme.getBodyMedium(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${result['status_code']}',
                  style: AppTheme.getBodyMedium(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirm ID: ${result['confirms_id']}',
                  style: AppTheme.getBodyMedium(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'New Record: ${result['new_record']}',
                  style: AppTheme.getBodyMedium(context),
                ),
                if (result['question']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Question: ${result['question']}',
                    style: AppTheme.getBodyMedium(context),
                  ),
                ],
              ],
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
    } catch (e) {
      print('Widget caught error: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Error',
              style: AppTheme.getBodyMedium(context).copyWith(
                color: Colors.red,
              ),
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
    return ElevatedButton(
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
    );
  }
}
