import '../../../exports.dart';
import '../../../providers/security_validation_provider.dart';

class RecentContactsTab extends ConsumerStatefulWidget {
  const RecentContactsTab({super.key});

  @override
  ConsumerState<RecentContactsTab> createState() => _RecentContactsTabState();
}

class _RecentContactsTabState extends ConsumerState<RecentContactsTab> {
  static final log = scopedLogger(LogCategory.gui);
  @override
  void initState() {
    super.initState();
    // Check security validation status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isSecurityValidated = ref.read(securityValidationNotifierProvider);
      log('Security validation status in RecentContactsTab: $isSecurityValidated');
      if (!isSecurityValidated) {
        log('Security not validated in RecentContactsTab, triggering refresh');
        ref.read(recentContactsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentContactsAsync = ref.watch(recentContactsProvider);

    return recentContactsAsync.when(
      data: (contacts) {
        log('Contacts received in RecentContactsTab: ${contacts.length}');
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
                        image: contact.profileImage != null && contact.profileImage!.isNotEmpty
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
