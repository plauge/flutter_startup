import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../models/confirm_state.dart';
import '../../../providers/confirms_provider.dart';

// Step6Widget - Calling confirmsRecieverFinish

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
  @override
  void initState() {
    super.initState();
    debugPrint('🔵 Step6Widget - initState called');
    debugPrint('🔵 Initial rawData: ${widget.rawData}');
    Future(() {
      if (!mounted) return;
      _updateConfirm();
    });
  }

  Future<void> _updateConfirm() async {
    if (!mounted) return;

    final confirmsId = widget.rawData['confirms_id'] as String?;
    debugPrint(
        '🔵 Step6Widget - _updateConfirm called with confirmsId: $confirmsId');

    if (confirmsId != null) {
      debugPrint('🔵 Step6Widget - Calling confirmsRecieverFinish');
      try {
        final response = await ref
            .read(confirmsConfirmProvider.notifier)
            .confirmsRecieverFinish(confirmsId: confirmsId);

        if (!mounted) return;

        debugPrint(
            '🔵 Step6Widget - confirmsRecieverFinish raw response: $response');

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
          debugPrint('🔵 Step6Widget - Updated data: $updatedData');
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
        debugPrint('❌ Step6Widget - Error in confirmsRecieverFinish: $e');
        if (mounted) {
          widget.onStateChange(
              ConfirmState.error, {'message': 'Der opstod en fejl: $e'});
        }
      }
    } else {
      debugPrint('❌ Step6Widget - confirmsId is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmState = ref.watch(confirmsConfirmProvider);
    debugPrint('🔵 Step6Widget - Current confirmState: $confirmState');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text(
        //   'Step 6',
        //   style: AppTheme.getBodyLarge(context),
        // ),
        // const SizedBox(height: 16),
        confirmState.when(
          data: (data) {
            debugPrint('🔵 Step6Widget - Rendering data state: $data');
            if (data is Map<String, dynamic> &&
                data['status_code'] == 200 &&
                data['data']?['success'] == true) {
              return const SizedBox();
            }
            return const SizedBox();
          },
          loading: () {
            debugPrint('🔵 Step6Widget - Rendering loading state');
            //return const CircularProgressIndicator();
            return const SizedBox();
          },
          error: (error, stack) {
            debugPrint('❌ Step6Widget - Rendering error state: $error');
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
