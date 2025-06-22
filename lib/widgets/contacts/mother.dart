import '../../exports.dart';
import 'tabs/all_contacts_tab.dart';
import 'tabs/recent_contacts_tab.dart';
import 'tabs/starred_contacts_tab.dart';
import 'tabs/new_contacts_tab.dart';
import 'tabs/pending_invitations_widget.dart';

class ContactsTabsWidgetClassic extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);

  const ContactsTabsWidgetClassic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the contacts count to determine if New tab should be shown
    final contactsCountAsync = ref.watch(contactsCountNotifierProvider);

    return contactsCountAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        log('[widgets/contacts/mother.dart][build] Error loading contacts count: $error');
        // On error, show all tabs as fallback
        return _buildTabsWidget(context, ref, showNewTab: true);
      },
      data: (contactsCount) {
        final bool showNewTab = true; //contactsCount >= 1;
        log('[widgets/contacts/mother.dart][build] Contacts count: $contactsCount, showing New tab: $showNewTab');
        return _buildTabsWidget(context, ref, showNewTab: showNewTab);
      },
    );
  }

  Widget _buildTabsWidget(BuildContext context, WidgetRef ref, {required bool showNewTab}) {
    final int tabLength = showNewTab ? 4 : 3;

    return DefaultTabController(
      length: tabLength,
      child: Column(
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              final TabController tabController = DefaultTabController.of(context);
              final List<String> tabTitles = showNewTab ? ['All', 'Recent', 'Starred', 'Pending'] : ['All', 'Recent', 'Starred'];
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
                              if (showNewTab) {
                                ref.read(newContactsProvider.notifier).refresh();
                              }
                              break;
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: showNewTab ? const [AllContactsTab(), RecentContactsTab(), StarredContactsTab(), PendingInvitationsWidget()] : const [AllContactsTab(), RecentContactsTab(), StarredContactsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// Created on 2025-01-02 13:30:00
