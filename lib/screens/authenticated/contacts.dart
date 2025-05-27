import '../../exports.dart';
import '../../widgets/contacts/tabs/all_contacts_tab.dart';
import '../../widgets/contacts/tabs/recent_contacts_tab.dart';
import '../../widgets/contacts/tabs/starred_contacts_tab.dart';
import '../../widgets/contacts/tabs/new_contacts_tab.dart';
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
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  final TabController tabController = DefaultTabController.of(context);
                  final List<String> tabTitles = ['All', 'Recent', 'Starred', 'New'];
                  final theme = Theme.of(context);
                  tabController.removeListener(() {}); // Fjern evt. gamle lyttere
                  tabController.addListener(() {
                    setState(() {});
                  });
                  final int currentIndex = tabController.index;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDDDDD), // Baggrundsfarve #DDD
                      borderRadius: BorderRadius.circular(7), // 7 px radius
                      // Ingen border
                    ),
                    child: Row(
                      children: List.generate(tabTitles.length, (index) {
                        final bool isSelected = currentIndex == index;
                        Color bgColor;
                        Color textColor;
                        if (isSelected) {
                          bgColor = const Color(0xFF014459); // Brug ønsket grøn/blå farve
                          textColor = Colors.white;
                        } else {
                          bgColor = const Color(0xFFDDDDDD); // Samme som tabbarens baggrund
                          textColor = const Color(0xFF014459); // Tekstfarve for inaktive tabs
                        }
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              tabController.animateTo(index);
                              switch (index) {
                                case 0:
                                  ref.read(contactsNotifierProvider.notifier).refresh();
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  tabTitles[index],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [AllContactsTab(), RecentContactsTab(), StarredContactsTab(), NewContactsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
