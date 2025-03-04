import '../../../exports.dart';
import '../../../providers/security_validation_provider.dart';

class RecentContactsTab extends ConsumerStatefulWidget {
  const RecentContactsTab({super.key});

  @override
  ConsumerState<RecentContactsTab> createState() => _RecentContactsTabState();
}

class _RecentContactsTabState extends ConsumerState<RecentContactsTab> {
  @override
  void initState() {
    super.initState();
    // Check security validation status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSecurityValidated = ref.read(securityValidationNotifierProvider);
      print(
          'Security validation status in RecentContactsTab: $isSecurityValidated');
      if (!isSecurityValidated) {
        print(
            'Security not validated in RecentContactsTab, triggering refresh');
        ref.read(recentContactsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentContactsAsync = ref.watch(recentContactsProvider);

    return recentContactsAsync.when(
      data: (contacts) {
        print('Contacts received in RecentContactsTab: ${contacts.length}');
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
