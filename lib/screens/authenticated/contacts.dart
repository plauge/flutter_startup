import '../../exports.dart';
import '../../widgets/contacts/contact_list_widget.dart';
import '../../widgets/contacts/add_contact_button.dart';

// A/B fjernet: Vi bruger kun bundknap-varianten med cirkulært plus-ikon

class ContactsScreen extends AuthenticatedScreen {
  static final log = scopedLogger(LogCategory.gui);
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
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts.contacts_header', fallback: 'Contacts'),
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: AppTheme.getParentContainerStyle(context).applyToContainer(
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ContactListWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: AppDimensionsTheme.getMedium(context),
            bottom: AppDimensionsTheme.getMedium(context),
            child: SafeArea(
              top: false,
              child: AddContactButton(
                onTap: () => context.go(RoutePaths.connect),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
