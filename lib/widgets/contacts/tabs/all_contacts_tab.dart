import '../../../exports.dart';
import '../../../providers/contacts_provider.dart';
import '../../../providers/security_validation_provider.dart';

class AllContactsTab extends ConsumerStatefulWidget {
  const AllContactsTab({super.key});

  @override
  ConsumerState<AllContactsTab> createState() => _AllContactsTabState();
}

class _AllContactsTabState extends ConsumerState<AllContactsTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Check security validation status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSecurityValidated = ref.read(securityValidationNotifierProvider);
      print('Security validation status: $isSecurityValidated');
      if (!isSecurityValidated) {
        print('Security not validated, triggering refresh');
        ref.read(contactsNotifierProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsNotifierProvider);

    return Column(
      children: [
        const PendingInvitationsWidget(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomTextFormField(
                labelText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: contactsAsync.when(
            data: (contacts) {
              print('Contacts received in AllContactsTab: ${contacts.length}');
              final filteredContacts = contacts.where((contact) {
                final searchTerm = _searchQuery.toLowerCase();
                return contact.firstName.toLowerCase().contains(searchTerm) ||
                    contact.lastName.toLowerCase().contains(searchTerm) ||
                    contact.company.toLowerCase().contains(searchTerm) ||
                    contact.email.toLowerCase().contains(searchTerm);
              }).toList();
              print('Filtered contacts: ${filteredContacts.length}');

              return Column(
                children: [
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No contacts found'
                                  : 'No contacts match your search',
                              style: AppTheme.getBodyMedium(context),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              return ContactListTile(
                                contact: contact,
                                onTap: () => context.go(
                                    '/contact-verification/${contact.contactId}'),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
