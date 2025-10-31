import '../../exports.dart';
import '../../widgets/contacts_realtime/zero_contacts.dart';
import '../../../services/i18n_service.dart';

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
    final contactsCountAsync = ref.watch(contactsCountNotifierProvider);

    return Scaffold(
      appBar: AuthenticatedAppBar(
        title: I18nService().t('screen_contacts.contacts_header', fallback: 'Contacts'),
        backRoutePath: '/home',
        showSettings: false,
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AppTheme.getParentContainerStyle(context).applyToContainer(
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
          ),
          Positioned(
            right: AppDimensionsTheme.getMedium(context),
            bottom: AppDimensionsTheme.getMedium(context),
            child: SafeArea(
              top: false,
              child: Material(
                color: const Color(0xFF005272),
                borderRadius: BorderRadius.circular(28),
                elevation: 2,
                child: InkWell(
                  key: const Key('action_context_button'),
                  onTap: () => context.go(RoutePaths.connect),
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: Color(0xFF005272),
                            ),
                          ),
                        ),
                        Gap(AppDimensionsTheme.getMedium(context)),
                        Text(
                          I18nService().t('screen_contacts.add_contact', fallback: 'Add contact'),
                          style: AppTheme.getBodyMedium(context).copyWith(
                            color: Colors.white,
                            fontSize: ((AppTheme.getBodyMedium(context).fontSize) ?? 16) * 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
