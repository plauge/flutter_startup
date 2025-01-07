import '../../exports.dart';

class ContactsScreen extends AuthenticatedScreen {
  ContactsScreen({super.key});

  // Static create method - den eneste måde at instantiere siden
  static Future<ContactsScreen> create() async {
    final screen = ContactsScreen();
    return AuthenticatedScreen.create(screen);
  }

  @override
  Widget buildAuthenticatedWidget(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedState state,
  ) {
    final contactsAsync = ref.watch(contactsProvider);

    print('\n=== Contacts Screen State ===');
    print('contactsAsync: $contactsAsync');

    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: 'Contacts',
        backRoutePath: '/home',
        showSettings: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RoutePaths.connect),
        child: const Icon(Icons.add),
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Recent'),
                Tab(text: 'Starred'),
                Tab(text: 'New'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  contactsAsync.when(
                    data: (contacts) {
                      print(
                          'Contacts data received: ${contacts.length} contacts');
                      return contacts.isEmpty
                          ? Center(
                              child: Text(
                                'No contacts found',
                                style: AppTheme.getBodyMedium(context),
                              ),
                            )
                          : ListView.builder(
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                print(
                                    'Building contact: ${contact.firstName} ${contact.lastName}');
                                return AppTheme.getParentContainerStyle(context)
                                    .applyToContainer(
                                  child: ListTile(
                                    leading: contact.profileImage != null
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                contact.profileImage!),
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
                                    trailing: contact.isNew
                                        ? const Icon(Icons.fiber_new)
                                        : null,
                                    onTap: () => context
                                        .go(RoutePaths.contactVerification),
                                  ),
                                );
                              },
                            );
                    },
                    loading: () {
                      print('Contacts loading...');
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    error: (error, stack) {
                      print('Contacts error: $error');
                      print('Stack trace: $stack');
                      return Center(
                        child: Text(
                          'Error: $error',
                          style: AppTheme.getBodyMedium(context),
                        ),
                      );
                    },
                  ),
                  // Placeholder for Recent tab
                  const Center(child: Text('Recent')),
                  // Placeholder for Starred tab
                  const Center(child: Text('Starred')),
                  // Placeholder for New tab
                  const Center(child: Text('New')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
