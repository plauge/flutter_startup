import '../../exports.dart';
import '../../widgets/contacts/tabs/all_contacts_tab.dart';
import '../../widgets/contacts/tabs/recent_contacts_tab.dart';
import '../../widgets/contacts/tabs/starred_contacts_tab.dart';
import '../../widgets/contacts/tabs/new_contacts_tab.dart';

class ContactsScreen extends AuthenticatedScreen {
  ContactsScreen({super.key});

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
    return Scaffold(
      appBar: const AuthenticatedAppBar(
        title: '> Contacts',
        backRoutePath: '/home',
        showSettings: false,
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
                    case 0:
                      ref.read(contactsProvider.notifier).refresh();
                      break;
                    case 1:
                      ref.read(recentContactsProvider.notifier).refresh();
                      break;
                    case 2:
                      ref.read(starredContactsProvider.notifier).refresh();
                      break;
                    case 3:
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
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    AllContactsTab(),
                    RecentContactsTab(),
                    StarredContactsTab(),
                    NewContactsTab(),
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
