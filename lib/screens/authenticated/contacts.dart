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
                  Column(
                    children: [
                      AppTheme.getParentContainerStyle(context)
                          .applyToContainer(
                        child: GestureDetector(
                          onTap: () =>
                              context.go(RoutePaths.contactVerification),
                          child: Text(
                            'Text 11',
                            style: AppTheme.getBodyMedium(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Placeholder for Recent tab
                  Center(child: Text('Recent')),
                  // Placeholder for Starred tab
                  Center(child: Text('Starred')),
                  // Placeholder for New tab
                  Center(child: Text('New')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
