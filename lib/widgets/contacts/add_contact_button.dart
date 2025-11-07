import '../../exports.dart';

class AddContactButton extends StatelessWidget {
  static final log = scopedLogger(LogCategory.gui);
  final VoidCallback onTap;

  const AddContactButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF005272),
      borderRadius: BorderRadius.circular(28),
      elevation: 2,
      child: InkWell(
        key: const Key('add_contact_button'),
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
  }
}

// Created on 2025-01-27 15:45:00
