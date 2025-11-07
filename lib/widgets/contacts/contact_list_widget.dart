import '../../exports.dart';
import '../../widgets/contacts_realtime/zero_contacts.dart';

class ContactListWidget extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const ContactListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsCountAsync = ref.watch(contactsCountNotifierProvider);

    return contactsCountAsync.when(
      data: (count) {
        log('widgets/contacts/contact_list_widget.dart - build: Contact count: $count');
        return count > 0 ? const ContactsRealtimeWidget() : const ZeroContactsWidget();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        log('widgets/contacts/contact_list_widget.dart - build: Error loading contact count: $error');
        return const ZeroContactsWidget(); // Fallback to zero contacts widget on error
      },
    );
  }
}

// Created on 2025-01-27 15:30:00
