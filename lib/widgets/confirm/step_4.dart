import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../providers/confirms_provider.dart';

class Step4Widget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const Step4Widget({
    super.key,
    required this.rawData,
    required this.onStateChange,
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
              answer: '1234',
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
    debugPrint(
        '🔵 Step4Widget - build called, _isInitialized: $_isInitialized');

    if (!_isInitialized) {
      debugPrint('🔵 Step4Widget - Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step4Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text(
        //   'Step 4',
        //   style: AppTheme.getBodyLarge(context),
        // ),
        // const SizedBox(height: 16),
        confirmState.when(
          data: (data) {
            debugPrint('🔵 Step4Widget - Rendering data state: $data');
            if (data is Map<String, dynamic> && data.isEmpty) {
              return const CircularProgressIndicator();
            }
            //return const Text('Confirmation completed');
            return const SizedBox();
          },
          loading: () {
            debugPrint('🔵 Step4Widget - Rendering loading state');
            //return const CircularProgressIndicator();
            return const SizedBox();
          },
          error: (error, stack) {
            debugPrint('❌ Step4Widget - Rendering error state: $error');
            // return Text(
            //   'Error: $error',
            //   style:
            //       AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
            // );
            return const SizedBox();
          },
        ),
      ],
    );
  }
}
