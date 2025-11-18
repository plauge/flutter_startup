import '../../../exports.dart';
import '../../../providers/contacts_provider.dart';
import '../../../providers/security_validation_provider.dart';
import '../../../utils/image_url_validator.dart';

class AllContactsTab extends ConsumerStatefulWidget {
  static final log = scopedLogger(LogCategory.gui);
  const AllContactsTab({super.key});

  @override
  ConsumerState<AllContactsTab> createState() => _AllContactsTabState();
}

class _AllContactsTabState extends ConsumerState<AllContactsTab> {
  static final log = scopedLogger(LogCategory.gui);
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Check security validation status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSecurityValidated = ref.read(securityValidationNotifierProvider);
      log('Security validation status: $isSecurityValidated');
      if (!isSecurityValidated) {
        log('Security not validated, triggering refresh');
        ref.read(contactsNotifierProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsNotifierProvider);

    return Column(
      children: [
        //const PendingInvitationsWidget(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
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
              log('Contacts received in AllContactsTab: ${contacts.length}');
              final filteredContacts = contacts.where((contact) {
                final searchTerm = _searchQuery.toLowerCase();
                return contact.firstName.toLowerCase().contains(searchTerm) || contact.lastName.toLowerCase().contains(searchTerm) || contact.company.toLowerCase().contains(searchTerm) || contact.email.toLowerCase().contains(searchTerm);
              }).toList();
              log('Filtered contacts: ${filteredContacts.length}');

              return Column(
                children: [
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty ? 'No contacts found' : 'No contacts match your search',
                              style: AppTheme.getBodyMedium(context),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              return Column(
                                children: [
                                  if (false) ...[
                                    ContactListTile(
                                      contact: contact,
                                      onTap: () => context.go('/contact-verification/${contact.contactId}'),
                                    ),
                                  ],
                                  CustomCardBatch(
                                    icon: CardBatchIcon.contacts,
                                    headerText: '${contact.firstName} ${contact.lastName}',
                                    bodyText: contact.company,
                                    onPressed: () {
                                      ApiLoggingService().logGuiInteraction(
                                        itemType: 'contact',
                                        itemId: contact.contactId,
                                        metadata: {
                                          'contactType': contact.contactType,
                                          'firstName': contact.firstName,
                                          'lastName': contact.lastName,
                                        },
                                      );
                                      context.go('/contact-verification/${contact.contactId}');
                                    },
                                    showArrow: true,
                                    backgroundColor: CardBatchBackgroundColor.green,
                                    image: ImageUrlValidator.isValidImageUrl(contact.profileImage)
                                        ? NetworkImage(
                                            '${contact.profileImage}?v=${DateTime.now().millisecondsSinceEpoch}',
                                            headers: const {
                                              'Cache-Control': 'no-cache',
                                            },
                                          )
                                        : null,
                                    level: contact.contactType.toString(),
                                  ),
                                  const SizedBox(height: 8),
                                ],
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
