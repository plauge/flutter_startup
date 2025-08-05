import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../exports.dart';
import '../../services/i18n_service.dart';

class ZeroContactsWidget extends StatelessWidget {
  static final log = scopedLogger(LogCategory.gui);

  const ZeroContactsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    log("widgets/contacts_realtime/zero_contacts.dart - build: Building ZeroContactsWidget");

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: I18nService().t('widgets_zero_contacts.no_contacts_title', fallback: 'No contacts yet'),
            type: CustomTextType.head,
            alignment: CustomTextAlignment.center,
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: I18nService().t('widgets_zero_contacts.add_contact_instruction', fallback: 'Tap the + button to add your first contact'),
            type: CustomTextType.bread,
            alignment: CustomTextAlignment.center,
          ),
        ],
      ),
    );
  }
}

// File created: 2025-01-27 14:15:00
