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
      body: Column(
        children: [
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Text 1',
              style: AppTheme.getBodyMedium(context),
            ),
          ),
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Text 2',
              style: AppTheme.getBodyMedium(context),
            ),
          ),
          AppTheme.getParentContainerStyle(context).applyToContainer(
            child: Text(
              'Text 3',
              style: AppTheme.getBodyMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}
