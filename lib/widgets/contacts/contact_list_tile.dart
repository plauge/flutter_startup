import '../../exports.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;

  const ContactListTile({
    super.key,
    required this.contact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                backgroundImage: NetworkImage(contact.profileImage),
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
    );
  }
}
