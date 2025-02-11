import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/confirm_state.dart';
import 'dart:async';

class DevTestWidget extends StatefulWidget {
  final Map<String, dynamic> rawData;
  final Function(ConfirmState, Map<String, dynamic>?) onStateChange;

  const DevTestWidget({
    super.key,
    required this.rawData,
    required this.onStateChange,
  });

  @override
  State<DevTestWidget> createState() => _DevTestWidgetState();
}

class _DevTestWidgetState extends State<DevTestWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:'
        '${_currentTime.minute.toString().padLeft(2, '0')}:'
        '${_currentTime.second.toString().padLeft(2, '0')}';
  }

  String get _formattedDate {
    return '${_currentTime.day.toString().padLeft(2, '0')}-'
        '${_currentTime.month.toString().padLeft(2, '0')}-'
        '${_currentTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Dev Test Widget',
          style: AppTheme.getBodyLarge(context),
        ),
        const SizedBox(height: 16),
        Text(
          _formattedDate,
          style: AppTheme.getBodyMedium(context),
        ),
        const SizedBox(height: 8),
        Text(
          _formattedTime,
          style: AppTheme.getBodyLarge(context),
        ),
      ],
    );
  }
}
