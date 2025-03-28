import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../models/confirm_state.dart';
import '../../../providers/confirms_provider.dart';

// Step5Widget - Calling confirmsInitiatorFinish

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
  @override
  void initState() {
    super.initState();
    debugPrint('🔵🔵🔵🔵🔵🔵🔵 Step5Widget - initState called');
    debugPrint('🔵🔵🔵🔵 Initial rawData: ${widget.rawData}');
    Future(() {
      if (!mounted) return;
      _updateConfirm();
    });
  }

  Future<void> _updateConfirm() async {
    if (!mounted) return;

    final confirmsId = widget.rawData['confirms_id'] as String?;
    debugPrint(
        '🔵🔵🔵🔵🔵 Step5Widget - _updateConfirm called with confirmsId: $confirmsId');

    if (confirmsId != null) {
      debugPrint('🔵🔵🔵🔵🔵 Step5Widget - Calling confirmsInitiatorFinish');
      try {
        final response = await ref
            .read(confirmsConfirmProvider.notifier)
            .confirmsInitiatorFinish(
              confirmsId: confirmsId,
            );

        if (!mounted) return;

        debugPrint(
            '🔵 Step5Widget - confirmsInitiatorFinish raw response: $response');

        if (response is Map<String, dynamic> &&
            response['status_code'] == 200 &&
            response['data']?['success'] == true) {
          final Map<String, dynamic> updatedData = {
            'status_code': 200,
            'data': {
              'message': response['data']['message'],
              'success': response['data']['success'],
              'payload': {
                ...widget.rawData,
                'status': response['data']['payload']['status']
              }
            }
          };
          debugPrint('🔵 Step5Widget - Updated data: $updatedData');
          if (mounted) {
            widget.onStateChange(ConfirmState.watch, updatedData);
          }
          return;
        }
        if (mounted) {
          widget.onStateChange(
              ConfirmState.error, {'message': 'Ugyldigt svar fra serveren'});
        }
      } catch (e) {
        debugPrint('❌ Step5Widget - Error in confirmsInitiatorFinish: $e');
        if (mounted) {
          widget.onStateChange(
              ConfirmState.error, {'message': 'Der opstod en fejl: $e'});
        }
      }
    } else {
      debugPrint('❌ Step5Widget - confirmsId is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step5Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text(
        //   'Step 5',
        //   style: AppTheme.getBodyLarge(context),
        // ),
        // const SizedBox(height: 16),
        confirmState.when(
          data: (data) {
            debugPrint('🔵 Step5Widget - Rendering data state: $data');
            if (data is Map<String, dynamic> &&
                data['status_code'] == 200 &&
                data['data']?['success'] == true) {
              return const SizedBox();
            }
            return const SizedBox();
          },
          loading: () {
            debugPrint('🔵 Step5Widget - Rendering loading state');
            //return const CircularProgressIndicator();
            return const SizedBox();
          },
          error: (error, stack) {
            debugPrint('❌ Step5Widget - Rendering error state: $error');
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
