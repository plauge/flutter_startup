import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Confirm extends StatelessWidget {
  final String contactId;

  const Confirm({
    super.key,
    required this.contactId,
  });

  void _handleConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Contact ID',
          style: AppTheme.getBodyMedium(context),
        ),
        content: Text(
          contactId,
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleConfirm(context),
      style: AppTheme.getPrimaryButtonStyle(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.arrow_forward),
          SizedBox(width: 8),
          Text('Swipe To Confirm'),
        ],
      ),
    );
  }
}
