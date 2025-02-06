import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'confirm.dart';

class ConfirmExistingWidget extends ConsumerWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const ConfirmExistingWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Existing Confirm Widget'),
    );
  }
}
