import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/confirms_provider.dart';
import 'initiator_widget.dart';
// import 'confirm_success_widget.dart';
// import 'confirm_existing_widget.dart';

enum ConfirmState { initial, newConfirm, existingConfirm }

class Confirm extends ConsumerStatefulWidget {
  final String contactId;

  const Confirm({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<Confirm> {
  ConfirmState currentState = ConfirmState.initial;
  Map<String, dynamic>? confirmData;

  void _handleStateChange(ConfirmState newState, Map<String, dynamic>? data) {
    setState(() {
      currentState = newState;
      confirmData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (currentState) {
      case ConfirmState.initial:
        return InitiatorWidget(
          contactId: widget.contactId,
          onStateChange: _handleStateChange,
        );
      case ConfirmState.newConfirm:
        return const Center(
          child: Text('TEST - Existing confirm state - Coming soon'),
        );
      case ConfirmState.existingConfirm:
        // Temporary placeholder until ConfirmExistingWidget is implemented
        return const Center(
          child: Text('Existing confirm state - Coming soon'),
        );
      // case ConfirmState.existingConfirm:
      //   return ConfirmExistingWidget(
      //     confirmData: confirmData!,
      //     onStateChange: _handleStateChange,
      //   );
    }
  }
}
