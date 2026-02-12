import '../../exports.dart';
import '../../providers/contact_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../utils/image_url_validator.dart';

class ContactListTile extends StatelessWidget {
  static final log = scopedLogger(LogCategory.gui);
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ContactListTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onDelete,
  });

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Contact',
            style: AppTheme.getBodyMedium(context),
          ),
          content: Text(
            'Are you sure you want to delete this contact?',
            style: AppTheme.getBodyMedium(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final success = await ref.read(contactNotifierProvider.notifier).deleteContact(contact.contactId);

                if (success && context.mounted) {
                  // Refresh all contact lists
                  await _refreshAllContactLists(ref);

                  // Call onDelete callback if provided
                  if (onDelete != null) onDelete!();

                  // Show success message
                  CustomSnackBar.show(
                    context: context,
                    text: 'Contact deleted successfully',
                    variant: CustomSnackBarVariant.success,
                  );
                } else if (context.mounted) {
                  // Show error message
                  CustomSnackBar.show(
                    context: context,
                    text: 'Failed to delete contact',
                    variant: CustomSnackBarVariant.error,
                  );
                }
              },
              child: Text(
                'Delete',
                style: AppTheme.getBodyMedium(context).copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to refresh all contact lists
  Future<void> _refreshAllContactLists(WidgetRef ref) async {
    // Refresh all contacts
    await ref.read(contactsNotifierProvider.notifier).refresh();

    // Refresh starred contacts
    await ref.read(starredContactsProvider.notifier).refresh();

    // Refresh recent contacts
    await ref.read(recentContactsProvider.notifier).refresh();

    // Refresh new contacts
    await ref.read(newContactsProvider.notifier).refresh();
  }


  @override
  Widget build(BuildContext context) {
    AppLogger.logSeparator('ContactListTile build');
    // Debug logging for profile image
    log('Contact ${contact.firstName} ${contact.lastName} - profileImage: "${contact.profileImage}" (null: ${contact.profileImage == null}, empty: ${contact.profileImage?.isEmpty ?? true})');

    return Consumer(
      builder: (context, ref, child) {
        return Dismissible(
          key: Key(contact.contactId),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            await _showDeleteConfirmation(context, ref);
            return false; // Always return false to prevent automatic dismissal
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: AppDimensionsTheme.getMedium(context)),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppDimensionsTheme.getSmall(context),
              vertical: AppDimensionsTheme.getSmall(context) / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              leading: ImageUrlValidator.isValidImageUrl(contact.profileImage)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        '${contact.profileImage}?v=${DateTime.now().millisecondsSinceEpoch}',
                        headers: const {
                          'Cache-Control': 'no-cache',
                        },
                      ),
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
              title: Text(
                '${contact.firstName} ${contact.lastName}',
                style: AppTheme.getBodyMedium(context),
              ),
              subtitle: Text(
                contact.company,
                style: AppTheme.getBodyMedium(context),
              ),
              trailing: contact.isNew ? const Icon(Icons.fiber_new) : null,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}
