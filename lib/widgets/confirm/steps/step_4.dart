import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../models/confirm_state.dart';
import '../../../providers/confirms_provider.dart';

// Step4Widget - Calling confirmsInitiatorUpdate

class Step4Widget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;
  final String answer;

  const Step4Widget({
    super.key,
    required this.rawData,
    required this.onStateChange,
    required this.answer,
  });

  @override
  ConsumerState<Step4Widget> createState() => _Step4WidgetState();
}

class _Step4WidgetState extends ConsumerState<Step4Widget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 Step4Widget - initState called');
    debugPrint('🔵 Initial rawData: ${widget.rawData}');

    Future(() {
      if (!mounted) return;
      debugPrint('🔵 Step4Widget - Starting delayed initialization');
      _updateConfirm();
      setState(() {
        _isInitialized = true;
        debugPrint('🔵 Step4Widget - Initialization completed');
      });
    });
  }

  Future<void> _updateConfirm() async {
    final confirmsId = widget.rawData['confirms_id'] as String?;
    debugPrint(
        '🔵 Step4Widget - _updateConfirm called with confirmsId: $confirmsId');

    if (confirmsId != null) {
      debugPrint('🔵 Step4Widget - Calling confirmsInitiatorUpdate');
      try {
        final response = await ref
            .read(confirmsConfirmProvider.notifier)
            .confirmsInitiatorUpdate(
              answer: widget.answer,
              confirmsId: confirmsId,
            );
        debugPrint(
            '🔵 Step4Widget - confirmsInitiatorUpdate raw response: $response');

        if (response is Map<String, dynamic>) {
          debugPrint('🔵 Step4Widget - Response is a Map: $response');
          if (response['data']?['payload'] != null) {
            final Map<String, dynamic> updatedData = {
              'status_code': 200,
              'data': {
                'message': response['data']['message'],
                'payload': {
                  ...widget.rawData,
                  'status': response['data']['payload']['status'],
                  'receiver_status': response['data']['payload']
                      ['receiver_status'],
                  'initiator_status': response['data']['payload']
                      ['initiator_status'],
                }
              }
            };

            debugPrint('🔵 Step4Widget - Updated data: $updatedData');
            widget.onStateChange(ConfirmState.watch, updatedData);
          }
        }
      } catch (e) {
        debugPrint('❌ Step4Widget - Error in confirmsInitiatorUpdate: $e');
      }
    } else {
      debugPrint('❌ Step4Widget - confirmsId is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox();
      // debugPrint('🔵 Step4Widget - Showing loading indicator');
      // return const Center(child: CircularProgressIndicator());
    }

    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step4Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        confirmState.when(
          data: (data) {
            return const SizedBox();
          },
          loading: () {
            return const SizedBox();
          },
          error: (error, stack) {
            return const SizedBox();
          },
        ),
      ],
    );
  }
}
