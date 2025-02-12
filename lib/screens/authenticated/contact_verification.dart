import '../../exports.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/confirm/confirm.dart';

class ContactVerificationScreen extends AuthenticatedScreen {
  final String contactId;

  ContactVerificationScreen({
    super.key,
    required this.contactId,
  });

  static Future<ContactVerificationScreen> create({
    required String contactId,
  }) async {
    final screen = ContactVerificationScreen(contactId: contactId);
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    // Call the API when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final exists = await ref
          .read(contactNotifierProvider.notifier)
          .checkContactExists(contactId);
      if (!exists) {
        if (context.mounted) {
          context.go('/home');
        }
        return;
      }

      // Load contact data after confirming existence
      await ref.read(contactNotifierProvider.notifier).loadContact(contactId);
      ref.read(contactNotifierProvider.notifier).markAsVisited(contactId);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AuthenticatedAppBar(
        title: 'Verification',
        backRoutePath: '/contacts',
        showSettings: false,
        onBeforeBack: () async {
          await ref
              .read(confirmsConfirmProvider.notifier)
              .confirmsDelete(contactsId: contactId);
        },
        onBeforeHome: () async {
          await ref
              .read(confirmsConfirmProvider.notifier)
              .confirmsDelete(contactsId: contactId);
        },
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final contactState = ref.watch(contactNotifierProvider);

          return contactState.when(
            data: (contact) => _buildContent(context, contact, ref),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error: $error',
                style: AppTheme.getBodyMedium(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Contact? contact, WidgetRef ref) {
    if (contact == null) {
      return Center(
        child: Text(
          'Contact not found',
          style: AppTheme.getBodyMedium(context),
        ),
      );
    }

    return AppTheme.getParentContainerStyle(context).applyToContainer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: contact.profileImage.isNotEmpty
                    ? NetworkImage(contact.profileImage)
                    : null,
                child: contact.profileImage.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              CustomText(
                text: '${contact.firstName} ${contact.lastName}',
                type: CustomTextType.head,
                alignment: CustomTextAlignment.center,
              ),
              CustomText(
                text: contact.company,
                type: CustomTextType.cardHead,
                alignment: CustomTextAlignment.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Security Level 1',
                  style: AppTheme.getBodyMedium(context)
                      .copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Confirm(
                contactId: contactId,
              ),
              const SizedBox(height: 24),
              const CustomText(
                text:
                    'To verify a contact, ensure they have you saved as a contact. Ask them to open your card and swipe to confirm.',
                type: CustomTextType.bread,
                alignment: CustomTextAlignment.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      print('UI: Star icon tapped for contact: $contactId');
                      ref
                          .read(contactNotifierProvider.notifier)
                          .toggleStar(contactId);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Icon(
                            contact.star ? Icons.star : Icons.star_border,
                            color: contact.star ? Colors.amber : null,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Star',
                            style: AppTheme.getBodyMedium(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
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
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true && context.mounted) {
                            final success = await ref
                                .read(contactNotifierProvider.notifier)
                                .deleteContact(contactId);

                            if (success && context.mounted) {
                              context.go('/contacts');
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete contact',
                                    style: AppTheme.getBodyMedium(context)
                                        .copyWith(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Icon(Icons.delete_outline),
                              const SizedBox(height: 4),
                              Text(
                                'Delete',
                                style: AppTheme.getBodyMedium(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
