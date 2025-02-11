import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../providers/confirms_provider.dart';

class Step3Widget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const Step3Widget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  ConsumerState<Step3Widget> createState() => _Step3WidgetState();
}

class _Step3WidgetState extends ConsumerState<Step3Widget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 Step3Widget - initState called');
    debugPrint('🔵 Initial rawData: ${widget.rawData}');

    Future(() {
      if (!mounted) return;
      debugPrint('🔵 Step3Widget - Starting delayed initialization');
      _updateConfirm();
      setState(() {
        _isInitialized = true;
        debugPrint('🔵 Step3Widget - Initialization completed');
      });
    });
  }

  Future<void> _updateConfirm() async {
    final confirmsId = widget.rawData['confirms_id'] as String?;
    debugPrint(
        '🔵 Step3Widget - _updateConfirm called with confirmsId: $confirmsId');

    if (confirmsId != null) {
      debugPrint('🔵 Step3Widget - Calling confirmsRecieverUpdate');
      try {
        final response = await ref
            .read(confirmsConfirmProvider.notifier)
            .confirmsRecieverUpdate(
              answer: '1234',
              confirmsId: confirmsId,
            );
        debugPrint(
            '🔵 Step3Widget - confirmsRecieverUpdate raw response: $response');

        if (response is Map<String, dynamic>) {
          debugPrint('🔵 Step3Widget - Response is a Map: $response');
          if (response['data']?['payload'] != null) {
            // Tilføj status_code og andre nødvendige felter
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

            debugPrint('🔵 Step3Widget - Updated data: $updatedData');
            widget.onStateChange(ConfirmState.watch, updatedData);
          }
        }
      } catch (e) {
        debugPrint('❌ Step3Widget - Error in confirmsRecieverUpdate: $e');
      }
    } else {
      debugPrint('❌ Step3Widget - confirmsId is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🔵 Step3Widget - build called, _isInitialized: $_isInitialized');

    if (!_isInitialized) {
      debugPrint('🔵 Step3Widget - Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step3Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step 3',
          style: AppTheme.getBodyLarge(context),
        ),
        const SizedBox(height: 16),
        confirmState.when(
          data: (data) {
            debugPrint('🔵 Step3Widget - Rendering data state: $data');
            if (data is Map<String, dynamic> && data.isEmpty) {
              return const CircularProgressIndicator();
            }
            return const Text('Confirmation completed');
          },
          loading: () {
            debugPrint('🔵 Step3Widget - Rendering loading state');
            return const CircularProgressIndicator();
          },
          error: (error, stack) {
            debugPrint('❌ Step3Widget - Rendering error state: $error');
            return Text(
              'Error: $error',
              style:
                  AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
            );
          },
        ),
      ],
    );
  }
}
