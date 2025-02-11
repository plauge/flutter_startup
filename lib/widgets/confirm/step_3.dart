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

        // Mere detaljeret response logging
        if (response is List && response.isNotEmpty) {
          final firstItem = response[0];
          debugPrint('🔵 Step3Widget - Response first item: $firstItem');

          if (firstItem is Map<String, dynamic> &&
              firstItem['data'] != null &&
              firstItem['data']['payload'] != null) {
            final payload = firstItem['data']['payload'];
            debugPrint('🔵 Step3Widget - Response payload: $payload');
            debugPrint('🔵 Step3Widget - New status: ${payload['status']}');

            widget.onStateChange(ConfirmState.watch, firstItem);
          } else {
            debugPrint('❌ Step3Widget - Invalid response structure');
          }
        } else if (response is Map<String, dynamic>) {
          debugPrint('🔵 Step3Widget - Response is a Map: $response');
          if (response['data']?['payload'] != null) {
            debugPrint('🔵 Step3Widget - Using Map response');
            widget.onStateChange(ConfirmState.watch, response);
          }
        } else {
          debugPrint(
              '❌ Step3Widget - Unexpected response type: ${response.runtimeType}');
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
