import '../../exports.dart';

class ActionsHolder extends ConsumerStatefulWidget {
  final String contactId;

  const ActionsHolder({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<ActionsHolder> createState() => _ActionsHolderState();
}

class _ActionsHolderState extends ConsumerState<ActionsHolder> {
  static final log = scopedLogger(LogCategory.gui);

  void _trackEvent(String eventName, Map<String, dynamic> properties) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track(eventName, {
      ...properties,
      'widget': 'actions_holder',
      'contact_id': widget.contactId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _handlePhoneAction() async {
    log('[widgets/confirm_v2/actions_holder.dart][_handlePhoneAction] Phone action triggered for contact: ${widget.contactId}');
    _trackEvent('actions_holder_phone_clicked', {});

    try {
      final phoneCodeCreateNotifier = ref.read(phoneCodeCreateNotifierProvider.notifier);

      // Call the detailed method to get the actual response data
      final response = await phoneCodeCreateNotifier.createPhoneCodeDetailed(widget.contactId);

      if (response != null && response.statusCode == 200) {
        log('✅ [widgets/confirm_v2/actions_holder.dart] Phone code created successfully');
        log('[widgets/confirm_v2/actions_holder.dart] Phone codes ID: ${response.data.payload.phoneCodesId}');
        log('[widgets/confirm_v2/actions_holder.dart] Confirm code: ${response.data.payload.confirmCode}');
        _trackEvent('actions_holder_phone_success', {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                I18nService().t(
                  'widget_actions_holder.phone_code_created_with_code',
                  fallback: 'Phone code created successfully: ${response.data.payload.confirmCode}',
                  variables: {'code': response.data.payload.confirmCode},
                ),
                style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        log('❌ [widgets/confirm_v2/actions_holder.dart] Phone code creation failed');
        _trackEvent('actions_holder_phone_failed', {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                I18nService().t(
                  'widget_actions_holder.phone_code_failed',
                  fallback: 'Failed to create phone code',
                ),
                style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      log('❌ [widgets/confirm_v2/actions_holder.dart] Exception in phone action: $e');
      _trackEvent('actions_holder_phone_exception', {'exception': e.toString()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              I18nService().t(
                'widget_actions_holder.phone_code_exception',
                fallback: 'Exception occurred while creating phone code',
              ),
              style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleTextAction() {
    log('[widgets/confirm_v2/actions_holder.dart][_handleTextAction] Text action triggered for contact: ${widget.contactId}');
    _trackEvent('actions_holder_text_clicked', {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            I18nService().t(
              'widget_actions_holder.text_demo_message',
              fallback: '%s - This is a demo text action for contact %s',
              variables: {
                'timestamp': DateTime.now().toString().substring(11, 19),
                'contact_id': widget.contactId.substring(0, 8),
              },
            ),
            style: AppTheme.getBodyMedium(context).copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Track widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackEvent('actions_holder_initialized', {});
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Phone Action Button
          GestureDetector(
            key: const Key('actions_holder_phone_button'),
            onTap: _handlePhoneAction,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone,
                    color: const Color(0xFF014459),
                    size: 32,
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    I18nService().t(
                      'widget_actions_holder.phone_label',
                      fallback: 'Phone',
                    ),
                    style: TextStyle(
                      color: const Color(0xFF014459),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Text Action Button
          GestureDetector(
            key: const Key('actions_holder_text_button'),
            onTap: _handleTextAction,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.message,
                    color: const Color(0xFF014459),
                    size: 32,
                  ),
                  Gap(AppDimensionsTheme.getSmall(context)),
                  Text(
                    I18nService().t(
                      'widget_actions_holder.text_label',
                      fallback: 'Text',
                    ),
                    style: TextStyle(
                      color: const Color(0xFF014459),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Created: 2025-01-16 18:00:00
