import '../../exports.dart';
import '../../providers/contacts_provider.dart';

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
    final starredContactsAsync = ref.watch(starredContactsProvider);
    final recentContactsAsync = ref.watch(recentContactsProvider);
    final newContactsAsync = ref.watch(newContactsProvider);

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
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              TabBar(
                onTap: (index) {
                  switch (index) {
                    case 0: // All
                      ref.read(contactsProvider.notifier).refresh();
                      break;
                    case 1: // Recent
                      ref.read(recentContactsProvider.notifier).refresh();
                      break;
                    case 2: // Starred
                      ref.read(starredContactsProvider.notifier).refresh();
                      break;
                    case 3: // New
                      ref.read(newContactsProvider.notifier).refresh();
                      break;
                  }
                },
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Recent'),
                  Tab(text: 'Starred'),
                  Tab(text: 'New'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
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
                                  return ContactListTile(
                                    contact: contact,
                                    onTap: () => context
                                        .go(RoutePaths.contactVerification),
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
                    // Recent contacts tab
                    recentContactsAsync.when(
                      data: (contacts) {
                        print(
                            'Recent contacts data received: ${contacts.length} contacts');
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
                                  return ContactListTile(
                                    contact: contact,
                                    onTap: () => context
                                        .go(RoutePaths.contactVerification),
                                  );
                                },
                              );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error: $error',
                          style: AppTheme.getBodyMedium(context),
                        ),
                      ),
                    ),
                    // Starred contacts tab
                    starredContactsAsync.when(
                      data: (contacts) {
                        print(
                            'Starred contacts data received: ${contacts.length} contacts');
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
                                  print(
                                      'Building starred contact: ${contact.firstName} ${contact.lastName}');
                                  return ContactListTile(
                                    contact: contact,
                                    onTap: () => context
                                        .go(RoutePaths.contactVerification),
                                  );
                                },
                              );
                      },
                      loading: () {
                        print('Starred contacts loading...');
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      error: (error, stack) {
                        print('Starred contacts error: $error');
                        print('Stack trace: $stack');
                        return Center(
                          child: Text(
                            'Error: $error',
                            style: AppTheme.getBodyMedium(context),
                          ),
                        );
                      },
                    ),
                    // New contacts tab
                    newContactsAsync.when(
                      data: (contacts) {
                        print(
                            'New contacts data received: ${contacts.length} contacts');
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
                                  return ContactListTile(
                                    contact: contact,
                                    onTap: () => context
                                        .go(RoutePaths.contactVerification),
                                  );
                                },
                              );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error: $error',
                          style: AppTheme.getBodyMedium(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
