import '../../../exports.dart';
import '../../../providers/security_validation_provider.dart';

class NewContactsTab extends ConsumerStatefulWidget {
  const NewContactsTab({super.key});

  @override
  ConsumerState<NewContactsTab> createState() => _NewContactsTabState();
}

class _NewContactsTabState extends ConsumerState<NewContactsTab> {
  @override
  void initState() {
    super.initState();
    // Check security validation status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSecurityValidated = ref.read(securityValidationNotifierProvider);
      print(
          'Security validation status in NewContactsTab: $isSecurityValidated');
      if (!isSecurityValidated) {
        print('Security not validated in NewContactsTab, triggering refresh');
        ref.read(newContactsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final newContactsAsync = ref.watch(newContactsProvider);

    return newContactsAsync.when(
      data: (contacts) {
        print('Contacts received in NewContactsTab: ${contacts.length}');
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
                  return Column(
                    children: [
                      if (false) ...[
                        ContactListTile(
                          contact: contact,
                          onTap: () => context
                              .go('/contact-verification/${contact.contactId}'),
                        ),
                      ],
                      CustomCardBatch(
                        icon: CardBatchIcon.contacts,
                        headerText: '${contact.firstName} ${contact.lastName}',
                        bodyText: contact.company,
                        onPressed: () => context
                            .go('/contact-verification/${contact.contactId}'),
                        showArrow: true,
                        backgroundColor: CardBatchBackgroundColor.green,
                        image: contact.profileImage != null
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
