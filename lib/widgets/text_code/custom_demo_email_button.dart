import '../../exports.dart';
import 'dart:io';

class CustomDemoEmailButton extends ConsumerStatefulWidget {
  final ValueNotifier<bool> isInputFocused;
  final Function(String action, Map<String, dynamic> properties) trackAction;

  const CustomDemoEmailButton({
    super.key,
    required this.isInputFocused,
    required this.trackAction,
  });

  @override
  ConsumerState<CustomDemoEmailButton> createState() => _CustomDemoEmailButtonState();
}

class _CustomDemoEmailButtonState extends ConsumerState<CustomDemoEmailButton> {
  static final log = scopedLogger(LogCategory.gui);

  void _onGetDemoEmailPressed() async {
    log('_onGetDemoEmailPressed: Get demo email button pressed from lib/widgets/text_code/custom_demo_email_button.dart');

    widget.trackAction('get_demo_email_pressed', {});

    try {
      log('_onGetDemoEmailPressed: Getting notifier instance');
      final notifier = ref.read(securityDemoTextCodeNotifierProvider.notifier);

      log('_onGetDemoEmailPressed: Calling sendDemoTextCode()');
      final success = await notifier.sendDemoTextCode();

      log('_onGetDemoEmailPressed: sendDemoTextCode() returned: $success');

      if (!mounted) {
        log('_onGetDemoEmailPressed: Widget not mounted, skipping UI updates');
        return;
      }

      if (success) {
        log('_onGetDemoEmailPressed: Success - showing green snackbar');
        widget.trackAction('get_demo_email_success', {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(I18nService().t('screen_text_code.demo_email_success', fallback: 'Check your email')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        log('_onGetDemoEmailPressed: Failed - success was false, showing red snackbar');
        widget.trackAction('get_demo_email_failed', {'reason': 'api_returned_false'});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(I18nService().t('screen_text_code.demo_email_error', fallback: 'An error occurred')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      log('_onGetDemoEmailPressed: Exception caught - $e');
      log('_onGetDemoEmailPressed: Stack trace - $stackTrace');

      widget.trackAction('get_demo_email_failed', {
        'reason': 'exception',
        'error': e.toString(),
      });

      if (!mounted) {
        log('_onGetDemoEmailPressed: Widget not mounted after exception, skipping UI updates');
        return;
      }

      log('_onGetDemoEmailPressed: Showing error snackbar due to exception');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18nService().t('screen_text_code.demo_email_error', fallback: 'An error occurred')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isInputFocused,
      builder: (context, isFocused, child) {
        // Skjul knappen når input feltet har focus (keyboard er synligt)
        if (isFocused) {
          return const SizedBox.shrink();
        }

        final button = Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CustomButton(
            key: const Key('get_demo_email_button'),
            onPressed: _onGetDemoEmailPressed,
            buttonType: CustomButtonType.secondary,
            text: I18nService().t('screen_text_code.get_demo_email', fallback: 'Get demo email'),
          ),
        );

        return Platform.isAndroid ? SafeArea(top: false, child: button) : button;
      },
    );
  }
}

// Created on 2025-11-01 at 15:12
