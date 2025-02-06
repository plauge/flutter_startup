import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/confirms_provider.dart';
import '../../models/api_response.dart';
import '../../models/confirm_payload.dart';
import '../../models/confirm_state.dart';
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
      debugPrint('🔍 Starting _handleConfirm');
      final result = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: contactId,
            question: "test",
          );
      onStateChange(ConfirmState.initiator_update, result);
    } catch (e) {
      debugPrint('❌ Error in _handleConfirm: $e');
      onStateChange(ConfirmState.error, {
        'message': 'Der opstod en fejl: $e',
      });
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
