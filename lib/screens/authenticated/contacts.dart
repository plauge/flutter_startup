import '../../exports.dart';
import '../../widgets/contacts_realtime/zero_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/i18n_service.dart';

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
    final contactsCountAsync = ref.watch(contactsCountNotifierProvider);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts.contacts_header', fallback: 'Contacts'),
        backRoutePath: '/home',
        showSettings: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RoutePaths.connect),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SvgPicture.asset(
          'assets/icons/add-connection.svg',
          width: 65,
          height: 65,
        ),
      ),
      body: AppTheme.getParentContainerStyle(context).applyToContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: contactsCountAsync.when(
                data: (count) {
                  log('screens/authenticated/contacts.dart - buildAuthenticatedWidget: Contact count: $count');
                  return count > 0 ? ContactsRealtimeWidget() : const ZeroContactsWidget();
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  log('screens/authenticated/contacts.dart - buildAuthenticatedWidget: Error loading contact count: $error');
                  return const ZeroContactsWidget(); // Fallback to zero contacts widget on error
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
