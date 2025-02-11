import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../providers/confirms_provider.dart';

class Step6Widget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const Step6Widget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  ConsumerState<Step6Widget> createState() => _Step6WidgetState();
}

class _Step6WidgetState extends ConsumerState<Step6Widget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 Step6Widget - initState called');
    debugPrint('🔵 Initial rawData: ${widget.rawData}');

    Future(() {
      if (!mounted) return;
      debugPrint('🔵 Step6Widget - Starting delayed initialization');
      _updateConfirm();
      setState(() {
        _isInitialized = true;
        debugPrint('🔵 Step6Widget - Initialization completed');
      });
    });
  }

  Future<void> _updateConfirm() async {
    final confirmsId = widget.rawData['confirms_id'] as String?;
    debugPrint(
        '🔵 Step6Widget - _updateConfirm called with confirmsId: $confirmsId');

    if (confirmsId != null) {
      debugPrint('🔵 Step6Widget - Calling confirmsRecieverFinish');
      try {
        final response = await ref
            .read(confirmsConfirmProvider.notifier)
            .confirmsRecieverFinish(
              confirmsId: confirmsId,
            );
        debugPrint(
            '🔵 Step6Widget - confirmsRecieverFinish raw response: $response');

        if (response is Map<String, dynamic>) {
          debugPrint('🔵 Step6Widget - Response is a Map: $response');
          if (response['status_code'] == 200) {
            final Map<String, dynamic> updatedData = {
              'status_code': 200,
              'data': {
                'message': response['data']['message'],
                'success': response['data']['success']
              }
            };
            debugPrint('🔵 Step6Widget - Updated data: $updatedData');
            widget.onStateChange(ConfirmState.watch, updatedData);
            return;
          }
        }
      } catch (e) {
        debugPrint('❌ Step6Widget - Error in confirmsRecieverFinish: $e');
      }
    } else {
      debugPrint('❌ Step6Widget - confirmsId is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🔵 Step6Widget - build called, _isInitialized: $_isInitialized');

    if (!_isInitialized) {
      debugPrint('🔵 Step6Widget - Showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step6Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step 6',
          style: AppTheme.getBodyLarge(context),
        ),
        const SizedBox(height: 16),
        confirmState.when(
          data: (data) {
            debugPrint('🔵 Step6Widget - Rendering data state: $data');
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
            debugPrint('🔵 Step6Widget - Rendering loading state');
            return const CircularProgressIndicator();
          },
          error: (error, stack) {
            debugPrint('❌ Step6Widget - Rendering error state: $error');
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
