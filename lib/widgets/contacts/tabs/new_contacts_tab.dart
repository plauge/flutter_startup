import '../../../exports.dart';

class NewContactsTab extends ConsumerWidget {
  const NewContactsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newContactsAsync = ref.watch(newContactsProvider);

    return newContactsAsync.when(
      data: (contacts) {
        return contacts.isEmpty
            ? Center(
                child: Text(
                  'No new contacts found',
                  style: AppTheme.getBodyMedium(context),
                ),
              )
            : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ContactListTile(
                    contact: contact,
                    onTap: () => context.go(RoutePaths.contactVerification),
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
