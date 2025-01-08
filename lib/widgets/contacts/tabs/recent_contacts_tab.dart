import '../../../exports.dart';

class RecentContactsTab extends ConsumerWidget {
  const RecentContactsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentContactsAsync = ref.watch(recentContactsProvider);

    return recentContactsAsync.when(
      data: (contacts) {
        return contacts.isEmpty
            ? Center(
                child: Text(
                  'No recent contacts found',
                  style: AppTheme.getBodyMedium(context),
                ),
              )
            : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ContactListTile(
                    contact: contact,
                    onTap: () => context
                        .go('/contact-verification/${contact.contactId}'),
                  );
                },
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: AppTheme.getBodyMedium(context),
        ),
      ),
    );
  }
}
