import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../providers/confirms_provider.dart';

class Step5Widget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const Step5Widget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  ConsumerState<Step5Widget> createState() => _Step5WidgetState();
}

class _Step5WidgetState extends ConsumerState<Step5Widget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 Step5Widget - initState called');
    debugPrint('🔵 Initial rawData: ${widget.rawData}');

    Future(() {
      if (!mounted) return;
      debugPrint('🔵 Step5Widget - Starting delayed initialization');
      _updateConfirm();
      setState(() {
        _isInitialized = true;
        debugPrint('🔵 Step5Widget - Initialization completed');
      });
    });
  }

  Future<void> _updateConfirm() async {
    final confirmsId = widget.rawData['confirms_id'] as String?;
    debugPrint(
        '🔵 Step5Widget - _updateConfirm called with confirmsId: $confirmsId');

    if (confirmsId != null) {
      debugPrint('🔵 Step5Widget - Calling confirmsInitiatorFinish');
      try {
        final response = await ref
            .read(confirmsConfirmProvider.notifier)
            .confirmsInitiatorFinish(
              confirmsId: confirmsId,
            );
        debugPrint(
            '🔵 Step5Widget - confirmsInitiatorFinish raw response: $response');

        if (response is Map<String, dynamic>) {
          debugPrint('🔵 Step5Widget - Response is a Map: $response');
          if (response['status_code'] == 200 &&
              response['data'] != null &&
              response['data']['success'] == true) {
            final Map<String, dynamic> updatedData = {
              'status_code': 200,
              'data': {
                'message': response['data']['message'],
                'success': response['data']['success'],
                'payload': {
                  ...widget.rawData,
                  'status': 6 // Opdater status til 5 når vi er færdige
                }
              }
            };
            debugPrint('🔵 Step5Widget - Updated data: $updatedData');
            widget.onStateChange(ConfirmState.watch, updatedData);
            return;
          }
        }
      } catch (e) {
        debugPrint('❌ Step5Widget - Error in confirmsInitiatorFinish: $e');
      }
    } else {
      debugPrint('❌ Step5Widget - confirmsId is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🔵 Step5Widget - build called, _isInitialized: $_isInitialized');

    if (!_isInitialized) {
      debugPrint('🔵 Step5Widget - Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step5Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step 5',
          style: AppTheme.getBodyLarge(context),
        ),
        const SizedBox(height: 16),
        confirmState.when(
          data: (data) {
            debugPrint('🔵 Step5Widget - Rendering data state: $data');
            if (data is Map<String, dynamic> &&
                data['status_code'] == 200 &&
                data['data']?['success'] == true) {
              return const Text('Bekræftelse gennemført',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold));
            }
            return const Text('Behandler bekræftelse...',
                style: TextStyle(fontSize: 16));
          },
          loading: () {
            debugPrint('🔵 Step5Widget - Rendering loading state');
            return const CircularProgressIndicator();
          },
          error: (error, stack) {
            debugPrint('❌ Step5Widget - Rendering error state: $error');
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
