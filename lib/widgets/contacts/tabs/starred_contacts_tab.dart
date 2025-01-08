import '../../../exports.dart';

class StarredContactsTab extends ConsumerWidget {
  const StarredContactsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final starredContactsAsync = ref.watch(starredContactsProvider);

    return starredContactsAsync.when(
      data: (contacts) {
        return contacts.isEmpty
            ? Center(
                child: Text(
                  'No starred contacts found',
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
