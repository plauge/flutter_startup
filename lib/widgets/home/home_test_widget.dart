import '../../exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class HomeTestWidget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const HomeTestWidget({super.key});

  void _showFCMTokenModal(BuildContext context, String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'FCM Token',
                      type: CustomTextType.head,
                    ),
                    IconButton(
                      key: const Key('fcm_modal_close_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                Gap(AppDimensionsTheme.getMedium(context)),
                // Token display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: SelectableText(
                    token,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                Gap(AppDimensionsTheme.getSmall(context)),
                CustomText(
                  text: 'Length: ${token.length} characters',
                  type: CustomTextType.small_bread,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyFCMToken(BuildContext context) async {
    try {
      // Get FCM token
      final String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        // Copy to clipboard
        await Clipboard.setData(ClipboardData(text: token));

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('FCM Token copied to clipboard!\nLength: ${token.length} characters'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Show FCM token in modal
          _showFCMTokenModal(context, token);
        }

        log('FCM Token copied to clipboard: ${token.substring(0, 20)}...');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get FCM token'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('Error getting FCM token: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // FCM Token Button (Debug/Test only)
        CustomButton(
          key: const Key('home_fcm_token_button'),
          text: 'Copy FCM Token 📋',
          onPressed: () => _copyFCMToken(context),
          buttonType: CustomButtonType.primary,
          icon: Icons.copy,
        ),
        Gap(AppDimensionsTheme.getSmall(context)),
        // StorageTestToken (only in debug mode)
        if (kDebugMode) const StorageTestToken(),
      ],
    );
  }
}

// Created on 2025-01-16 at 17:05
