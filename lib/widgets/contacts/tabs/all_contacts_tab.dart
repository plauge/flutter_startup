import '../../../exports.dart';

class AllContactsTab extends ConsumerStatefulWidget {
  const AllContactsTab({super.key});

  @override
  ConsumerState<AllContactsTab> createState() => _AllContactsTabState();
}

class _AllContactsTabState extends ConsumerState<AllContactsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Column(
      children: [
        Gap(AppDimensionsTheme.getLarge(context)),
        const Center(
          child: CustomText(
            text: 'Dine invitationer',
            type: CustomTextType.bread,
          ),
        ),
        Gap(AppDimensionsTheme.getLarge(context)),
        ref.watch(invitationLevel3WaitingForInitiatorProvider).when(
              data: (invitations) {
                if (invitations is List && invitations.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = invitations[index];
                      return ContactListTile(
                        contact: Contact(
                          contactId: invitation['contact_id'],
                          firstName: invitation['first_name'],
                          lastName: invitation['last_name'],
                          company: invitation['company'] ?? '',
                          email: invitation['email'],
                          profileImage: invitation['profile_image'] ?? '',
                          isNew: invitation['is_new'] == 1,
                          star: invitation['star'] ?? false,
                          count: invitation['count'] ?? 0,
                          contactType: invitation['contact_type'],
                        ),
                        onTap: () {
                          context.go(
                              '${RoutePaths.confirmConnection}?invite=${invitation['contact_id']}');
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: AppTheme.getBodyMedium(context),
                ),
              ),
            ),
        Gap(AppDimensionsTheme.getLarge(context)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: AppTheme.getTextFieldDecoration(context).copyWith(
              hintText: 'Search contacts...',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: contactsAsync.when(
            data: (contacts) {
              final filteredContacts = contacts.where((contact) {
                final searchTerm = _searchQuery.toLowerCase();
                return contact.firstName.toLowerCase().contains(searchTerm) ||
                    contact.lastName.toLowerCase().contains(searchTerm) ||
                    contact.company.toLowerCase().contains(searchTerm) ||
                    contact.email.toLowerCase().contains(searchTerm);
              }).toList();

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
