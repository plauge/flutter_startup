import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../providers/confirms_provider.dart';
import '../../../../../models/confirm_state.dart';

class StateHandler {
  static void startWaitingTimer({
    required VoidCallback onStateChange,
  }) {
    developer.log('Starting timer to change state to waiting',
        name: 'StateHandler');

    Timer(const Duration(milliseconds: 150), () {
      developer.log('Timer completed, requesting state change to waiting',
          name: 'StateHandler');
      onStateChange();
    });
  }

  static Future<void> handleConfirm({
    required WidgetRef ref,
    required String? contactId,
    required String question,
    required Function(ConfirmState, Map<String, dynamic>?) onConfirmStateChange,
  }) async {
    try {
      developer.log('🔍 Starting handleConfirm', name: 'StateHandler');

      if (contactId == null) {
        developer.log('❌ Error in handleConfirm: contactId is null',
            name: 'StateHandler');
        onConfirmStateChange(ConfirmState.error, {
          'message': 'Contact ID is missing',
        });
        return;
      }

      final result = await ref.read(confirmsConfirmProvider.notifier).confirm(
            contactsId: contactId,
            question: question,
          );

      onConfirmStateChange(ConfirmState.initiator_update, result);
    } catch (e) {
      developer.log('❌ Error in handleConfirm: $e', name: 'StateHandler');
      onConfirmStateChange(ConfirmState.error, {
        'message': 'Der opstod en fejl: $e',
      });
    }
  }
}
