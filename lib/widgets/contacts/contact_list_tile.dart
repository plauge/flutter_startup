import '../../exports.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ContactListTile({
    super.key,
    required this.contact,
    this.onTap,
    this.onDelete,
  });

  Future<void> _showDeleteConfirmation(BuildContext context) async {
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
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) onDelete!();
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(contact.contactId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _showDeleteConfirmation(context);
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
          leading: contact.profileImage.isNotEmpty
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
  }
}
