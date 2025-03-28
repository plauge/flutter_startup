import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/confirm_state.dart';
import '../../../theme/app_theme.dart';
import '../confirm.dart';
import 'dart:developer' as developer;

class ConfirmSuccessWidget extends ConsumerWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const ConfirmSuccessWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  // Intern data parsing
  String? get confirmsId {
    developer.log('ConfirmSuccessWidget rawData: $rawData');
    if (rawData.isEmpty) return null;
    try {
      return rawData['confirms_id'] as String;
    } catch (e) {
      developer.log('Error getting confirmsId: $e');
      developer.log('rawData type: ${rawData.runtimeType}');
      developer.log('rawData keys: ${rawData.keys.toList()}');
      return null;
    }
  }

  String? get question {
    if (rawData.isEmpty) return null;
    try {
      return rawData['question'] as String;
    } catch (e) {
      developer.log('Error getting question: $e');
      return null;
    }
  }

  // Widget-specifik logik
  void _handleSomeAction() {
    // Widget-specifik logik her
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building ConfirmSuccessWidget with rawData: $rawData');

    if (rawData.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (confirmsId != null) Text('Confirm ID: $confirmsId'),
        if (question != null) Text('Question: $question'),
        // ... mere UI
      ],
    );
  }
}
