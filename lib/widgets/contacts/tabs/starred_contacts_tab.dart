import '../../../exports.dart';
import '../../../providers/security_validation_provider.dart';
import '../../../utils/image_url_validator.dart';

class StarredContactsTab extends ConsumerStatefulWidget {
  const StarredContactsTab({super.key});

  @override
  ConsumerState<StarredContactsTab> createState() => _StarredContactsTabState();
}

class _StarredContactsTabState extends ConsumerState<StarredContactsTab> {
  static final log = scopedLogger(LogCategory.gui);
  @override
  void initState() {
    super.initState();
    // Check security validation status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSecurityValidated = ref.read(securityValidationNotifierProvider);
      log('Security validation status in StarredContactsTab: $isSecurityValidated');
      if (!isSecurityValidated) {
        log('Security not validated in StarredContactsTab, triggering refresh');
        ref.read(starredContactsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final starredContactsAsync = ref.watch(starredContactsProvider);

    return starredContactsAsync.when(
      data: (contacts) {
        log('Contacts received in StarredContactsTab: ${contacts.length}');
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
                        onPressed: () => context.go('/contact-verification/${contact.contactId}'),
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
