import '../../exports.dart';
import '../../widgets/contacts/mother.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      appBar: const AuthenticatedAppBar(
        title: 'Contacts',
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
          children: [
            // const Expanded(
            //   child: ContactsTabsWidgetClassic(),
            // ),
            //const ContactsTabsWidgetClassic(),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Connect',
              type: CustomTextType.bread,
            )
          ],
        ),
      ),
    );
  }
}
