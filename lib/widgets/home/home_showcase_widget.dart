import '../../exports.dart';
import 'package:showcaseview/showcaseview.dart';

/// Helper widget to wrap a target widget with Showcase
class ShowcaseWrapper extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final Widget child;
  final bool isLast;
  final VoidCallback? onComplete;

  const ShowcaseWrapper({
    super.key,
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
    this.isLast = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = I18nService();

    final List<TooltipActionButton> actions = [];

    // Add Next button (or Finish if last) - aligned to right
    if (isLast) {
      actions.add(
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: i18n.t('screen_home.showcase_finish_button', fallback: 'Finish'),
          onTap: () {
            if (onComplete != null) {
              onComplete!();
            }
            ShowCaseWidget.of(context).dismiss();
          },
        ),
      );
    } else {
      actions.add(
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: i18n.t('screen_home.showcase_next_button', fallback: 'Next'),
          onTap: () {
            ShowCaseWidget.of(context).next();
          },
        ),
      );
    }

    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      targetBorderRadius: BorderRadius.circular(8),
      tooltipBackgroundColor: Colors.white,
      textColor: Colors.black87,
      tooltipActions: actions,
      tooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.end, // Align Next button to right
      ),
      child: child,
    );
  }
}

/// Helper to start showcase sequence
void startHomeShowcase(BuildContext context, List<GlobalKey> keys) {
  if (!context.mounted) {
    debugPrint('Context not mounted, cannot start showcase');
    return;
  }

  try {
    final showcaseWidget = ShowCaseWidget.of(context);
    showcaseWidget.startShowCase(keys);
    debugPrint('Showcase started with ${keys.length} keys');
  } catch (e) {
    debugPrint('Error starting showcase: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
  }
}

// Created on 2025-12-14 at 05:00:00
