import '../../exports.dart';
import '../../widgets/home/showcase_button_helper.dart';
import 'package:showcaseview/showcaseview.dart';

class AddContactButton extends StatelessWidget {
  static final log = scopedLogger(LogCategory.gui);
  final VoidCallback onTap;
  final GlobalKey? showcaseKey;
  final bool isLast;
  final VoidCallback? onShowcaseComplete;

  const AddContactButton({
    super.key,
    required this.onTap,
    this.showcaseKey,
    this.isLast = false,
    this.onShowcaseComplete,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = I18nService();

    final buttonWidget = Material(
      color: const Color(0xFF005272),
      borderRadius: BorderRadius.circular(28),
      elevation: 2,
      child: InkWell(
        key: showcaseKey == null ? const Key('add_contact_button') : null,
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFF005272),
                  ),
                ),
              ),
              Gap(AppDimensionsTheme.getMedium(context)),
              Text(
                I18nService().t('screen_contacts.add_contact', fallback: 'Add contact'),
                style: AppTheme.getBodyMedium(context).copyWith(
                  color: Colors.white,
                  fontSize: ((AppTheme.getBodyMedium(context).fontSize) ?? 16) * 0.9,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Showcase if showcaseKey is provided
    if (showcaseKey != null) {
      final List<TooltipActionButton> actions = [];

      if (isLast) {
        actions.add(
          ShowcaseButtonHelper.createPrimaryButton(
            text: i18n.t('screen_home.showcase_finish_button', fallback: 'Finish'),
            onTap: () {
              if (onShowcaseComplete != null) {
                onShowcaseComplete!();
              }
              ShowCaseWidget.of(context).dismiss();
            },
          ),
        );
      } else {
        actions.add(
          ShowcaseButtonHelper.createPrimaryButton(
            text: i18n.t('screen_home.showcase_next_button', fallback: 'Next'),
            onTap: () {
              ShowCaseWidget.of(context).next();
            },
          ),
        );
      }

      return Showcase(
        key: showcaseKey!,
        title: i18n.t('screen_home.showcase_add_contact_title', fallback: 'Add Contact'),
        description: i18n.t('screen_home.showcase_add_contact_description', fallback: 'Tap this button to add a new contact to your network.'),
        targetBorderRadius: BorderRadius.circular(8),
        tooltipBackgroundColor: Colors.white,
        textColor: Colors.black87,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0A3751), // CustomTextType.info color
        ),
        descTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF0A3751), // CustomTextType.bread color
        ),
        tooltipPosition: TooltipPosition.top, // Tooltip appears above button, pointing downward
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 16px internal padding, 20px horizontal margin from screen edges
        tooltipActions: actions,
        tooltipActionConfig: const TooltipActionConfig(
          alignment: MainAxisAlignment.end, // Align Next button to right
        ),
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}

// Created on 2025-01-27 15:45:00
