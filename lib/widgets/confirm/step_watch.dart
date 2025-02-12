import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import '../../providers/confirms_provider.dart';
import 'dart:async';

class StepWatchWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const StepWatchWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  ConsumerState<StepWatchWidget> createState() => _StepWatchWidgetState();
}

class _StepWatchWidgetState extends ConsumerState<StepWatchWidget> {
  Timer? _timer;
  bool _isInitialized = false;
  int _pollCount = 0; // Add counter to track number of polls

  // Add method to determine polling interval
  Duration _getPollingInterval() {
    if (_pollCount < 20) {
      return const Duration(milliseconds: 500);
    } else if (_pollCount < 40) {
      return const Duration(seconds: 1);
    } else {
      return const Duration(seconds: 2);
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay the initialization to avoid build-time modifications
    Future(() {
      if (!mounted) return;
      _startWatching();
      setState(() {
        _isInitialized = true;
      });
    });
  }

  void _startWatching() {
    final confirmsId = widget.rawData['confirms_id'] as String?;
    if (confirmsId != null) {
      // Initial call
      ref.read(confirmsWatchProvider.notifier).watch(confirmsId: confirmsId);
      _pollCount = 0; // Reset counter

      void schedulePoll() {
        if (!mounted) return;
        _timer = Timer(_getPollingInterval(), () {
          if (!mounted) return;
          ref
              .read(confirmsWatchProvider.notifier)
              .watch(confirmsId: confirmsId);
          _pollCount++; // Increment counter
          schedulePoll(); // Schedule next poll
        });
      }

      schedulePoll(); // Start polling
    }
  }

  void _handleWatchData(Map<String, dynamic>? data) {
    if (!mounted) return;

    // Hvis data er null eller tomt, fortsæt med at watche
    if (data == null || data.isEmpty) {
      return;
    }

    final payload = data['data']?['payload'] as Map<String, dynamic>?;
    if (payload == null) {
      return; // Fortsæt med at watche i stedet for at gå til error state
    }

    final status = payload['status'] as int?;
    if (status == null) {
      return; // Fortsæt med at watche i stedet for at gå til error state
    }

    // Kun kald onStateChange hvis vi har en valid status ændring
    widget.onStateChange(
      status == 2 ? ConfirmState.step_3 : ConfirmState.watch,
      data,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final watchData = ref.watch(confirmsWatchProvider);
    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    ref.listen(confirmsWatchProvider, (previous, next) {
      next.whenData(_handleWatchData);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedTime,
          style: AppTheme.getBodyMedium(context),
        ),
        Text(
          'Step Watch',
          style: AppTheme.getBodyLarge(context),
        ),
        const SizedBox(height: 16),
        watchData.when(
          data: (data) {
            if (data.isEmpty) {
              return const Text('Waiting for confirmation...');
            }
            final payload = data['data']?['payload'] as Map<String, dynamic>?;
            if (payload == null) {
              return const Text('Waiting for data...');
            }
            return Text(
              'Status: ${payload['status']}',
              style: AppTheme.getBodyMedium(context),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text(
            'Error: $error',
            style: AppTheme.getBodyMedium(context).copyWith(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
