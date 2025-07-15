import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../exports.dart';
import '../../../services/i18n_service.dart';
import '../../core/constants/contacts_tab_state_constants.dart';

class ContactsRealtimeWidget extends StatefulWidget {
  static final log = scopedLogger(LogCategory.gui);

  const ContactsRealtimeWidget({super.key});

  @override
  State<ContactsRealtimeWidget> createState() => _ContactsRealtimeWidgetState();
}

class _ContactsRealtimeWidgetState extends State<ContactsRealtimeWidget> with SingleTickerProviderStateMixin {
  static final log = scopedLogger(LogCategory.gui);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    log("widgets/contacts_realtime/contacts_realtime.dart - initState: Initializing TabController with 4 tabs");
    final initialIndex = ContactsTabStateConstants.getLastActiveTabIndex();
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    log("widgets/contacts_realtime/contacts_realtime.dart - initState: Set initial tab index to $initialIndex");

    // Listen to tab changes to save the active tab
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final newIndex = _tabController.index;
      ContactsTabStateConstants.setLastActiveTabIndex(newIndex);
      log("widgets/contacts_realtime/contacts_realtime.dart - _onTabChanged: Saved tab index $newIndex");
    }
  }

  @override
  void dispose() {
    log("widgets/contacts_realtime/contacts_realtime.dart - dispose: Disposing TabController");
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("widgets/contacts_realtime/contacts_realtime.dart - build: Building ContactsRealtimeWidget");
    return GestureDetector(
      onTap: () {
        log("widgets/contacts_realtime/contacts_realtime.dart - build: Dismissing keyboard on tap");
        // Fjern focus fra alle input felter og luk keyboardet
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const CustomText(
            //   text: 'Realtime Contacts',
            //   type: CustomTextType.head,
            // ),
            // Gap(AppDimensionsTheme.getSmall(context)),
            _buildCustomTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ContactsTabView(sortType: ContactsSortType.firstName),
                  _ContactsTabView(sortType: ContactsSortType.createdAt),
                  _ContactsTabView(sortType: ContactsSortType.starred),
                  _ContactsTabView(sortType: ContactsSortType.newest),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    log("widgets/contacts_realtime/contacts_realtime.dart - _buildCustomTabBar: Building custom tab bar");
    final List<String> tabTitles = [
      I18nService().t('widgets_contacts.contacts_tab_all', fallback: 'All'),
      I18nService().t('widgets_contacts.contacts_tab_recent', fallback: 'Recent'),
      I18nService().t('widgets_contacts.contacts_tab_star', fallback: 'Star'),
      I18nService().t('widgets_contacts.contacts_tab_new', fallback: 'New'),
    ];
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final int currentIndex = _tabController.index;
        log("widgets/contacts_realtime/contacts_realtime.dart - _buildCustomTabBar: Current tab index: $currentIndex");
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFDDDDDD), // Baggrundsfarve #DDD
            borderRadius: BorderRadius.circular(7), // 7 px radius
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
                    log("widgets/contacts_realtime/contacts_realtime.dart - _buildCustomTabBar: Tab pressed: ${tabTitles[index]} (index: $index)");
                    _tabController.animateTo(index);
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
    );
  }
}

enum ContactsSortType {
  firstName,
  createdAt,
  starred,
  newest,
}

class _ContactsTabView extends ConsumerStatefulWidget {
  static final log = scopedLogger(LogCategory.gui);
  final ContactsSortType sortType;

  const _ContactsTabView({required this.sortType});

  @override
  ConsumerState<_ContactsTabView> createState() => _ContactsTabViewState();
}

class _ContactsTabViewState extends ConsumerState<_ContactsTabView> {
  static final log = scopedLogger(LogCategory.gui);
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    AppLogger.log(LogCategory.gui, "widgets/contacts_realtime/contacts_realtime.dart - _ContactsTabViewState build: Building tab view for ${widget.sortType}");

    log("widgets/contacts_realtime/contacts_realtime.dart - _ContactsTabViewState build: Building tab view for ${widget.sortType}");
    final contactsStream = ref.watch(contactsRealtimeNotifierProvider);

    return contactsStream.when(
      data: (contacts) {
        log("widgets/contacts_realtime/contacts_realtime.dart - build: Received ${contacts.length} contacts from stream");
        return _buildContactsList(context, ref, contacts);
      },
      loading: () {
        log("widgets/contacts_realtime/contacts_realtime.dart - build: Loading contacts stream");
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        log("widgets/contacts_realtime/contacts_realtime.dart - build: Error loading contacts: $error");
        return _buildErrorWidget(context, error);
      },
    );
  }

  Widget _buildContactsList(BuildContext context, WidgetRef ref, List<ContactRealtime> contacts) {
    AppLogger.log(LogCategory.gui, "widgets/contacts_realtime/contacts_realtime.dart - _buildContactsList: Building contacts list with ${contacts.length} contacts, sortType: ${widget.sortType}");
    log("widgets/contacts_realtime/contacts_realtime.dart - _buildContactsList: Building contacts list with ${contacts.length} contacts, sortType: ${widget.sortType}");
    // Filter and sort contacts based on tab type
    List<ContactRealtime> filteredContacts = _filterAndSortContacts(contacts);

    // Apply search filter for "All" tab only
    if (widget.sortType == ContactsSortType.firstName && _searchQuery.isNotEmpty) {
      log("widgets/contacts_realtime/contacts_realtime.dart - _buildContactsList: Applying search filter: '$_searchQuery'");
      filteredContacts = filteredContacts.where((contact) {
        final searchTerm = _searchQuery.toLowerCase();
        final firstName = contact.firstName?.toLowerCase() ?? '';
        final lastName = contact.lastName?.toLowerCase() ?? '';
        final company = contact.company?.toLowerCase() ?? '';
        final email = contact.email?.toLowerCase() ?? '';

        return firstName.contains(searchTerm) || lastName.contains(searchTerm) || company.contains(searchTerm) || email.contains(searchTerm);
      }).toList();
      log("widgets/contacts_realtime/contacts_realtime.dart - _buildContactsList: Search filtered to ${filteredContacts.length} contacts");
    }

    return Column(
      children: [
        // Show search field only for "All" tab
        if (widget.sortType == ContactsSortType.firstName) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: CustomTextFormField(
              labelText: I18nService().t('widgets_contacts.contacts_search_contacts', fallback: 'Search contacts...'),
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                log("widgets/contacts_realtime/contacts_realtime.dart - _buildContactsList: Search query changed: '$value'");
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
        Expanded(
          child: filteredContacts.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return Column(
                      children: [
                        CustomCardBatch(
                          icon: CardBatchIcon.contacts,
                          headerText: '${contact.firstName ?? ''} ${contact.lastName ?? ''}',
                          bodyText: contact.company ?? '',
                          onPressed: () => _handleContactTap(context, contact),
                          showArrow: true,
                          backgroundColor: CardBatchBackgroundColor.green,
                          image: contact.profileImage.isNotEmpty ? NetworkImage(contact.profileImage) : null,
                          level: contact.contactType.toString(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<ContactRealtime> _filterAndSortContacts(List<ContactRealtime> contacts) {
    AppLogger.log(LogCategory.gui, "widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Filtering and sorting ${contacts.length} contacts by ${widget.sortType}");
    log("widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Filtering and sorting ${contacts.length} contacts by ${widget.sortType}");
    List<ContactRealtime> filtered = List.from(contacts);

    switch (widget.sortType) {
      case ContactsSortType.firstName:
        // Sort by first name alphabetically
        filtered.sort((a, b) {
          final aName = a.firstName ?? '';
          final bName = b.firstName ?? '';
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        log("widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Sorted by firstName alphabetically");
        break;
      case ContactsSortType.createdAt:
        // Sort by created_at (recent first)
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        log("widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Sorted by createdAt (recent first)");
        break;
      case ContactsSortType.starred:
        // Only starred contacts
        filtered = filtered.where((contact) => contact.star).toList();
        // Sort starred by first name
        filtered.sort((a, b) {
          final aName = a.firstName ?? '';
          final bName = b.firstName ?? '';
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        log("widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Filtered to ${filtered.length} starred contacts");
        break;
      case ContactsSortType.newest:
        // Sort by created_at (newest first)
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        log("widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Sorted by newest first");
        break;
    }

    log("widgets/contacts_realtime/contacts_realtime.dart - _filterAndSortContacts: Final result: ${filtered.length} contacts");
    return filtered;
  }

  // Retry loading contacts
  void _retryLoadContacts() {
    log("widgets/contacts_realtime/contacts_realtime.dart - _retryLoadContacts: Refreshing contacts provider");
    ref.refresh(contactsRealtimeNotifierProvider);
  }

  // Handle contact tap for navigation
  void _handleContactTap(BuildContext context, ContactRealtime contact) {
    AppLogger.log(LogCategory.gui, "widgets/contacts_realtime/contacts_realtime.dart - _handleContactTap: Contact tapped: ${contact.firstName} ${contact.lastName}, contactType: ${contact.contactType}");
    log("widgets/contacts_realtime/contacts_realtime.dart - _handleContactTap: Contact tapped: ${contact.firstName} ${contact.lastName}, contactType: ${contact.contactType}");
    // Navigation based on contact type - similar to pending_invitations_widget.dart
    final contactType = contact.contactType;
    final contactId = contact.contactId ?? contact.contactsRealtimeId;
    final invitationLevel1Id = contact.invitationLevel1Id;
    final invitationLevel3Id = contact.invitationLevel3Id;

    if (contactType == -1) {
      log("widgets/contacts_realtime/contacts_realtime.dart - _handleContactTap: Navigating to level1 confirm connection with ID: $invitationLevel1Id");
      context.go('${RoutePaths.level1ConfirmConnection}?invite=$invitationLevel1Id');
    } else if (contactType == -3) {
      log("widgets/contacts_realtime/contacts_realtime.dart - _handleContactTap: Navigating to level3 confirm connection with ID: $invitationLevel3Id");
      context.go('${RoutePaths.level3ConfirmConnection}?invite=$invitationLevel3Id');
    } else {
      log("widgets/contacts_realtime/contacts_realtime.dart - _handleContactTap: Navigating to contact verification for contactId: $contactId");
      // Default navigation for other contact types
      context.go('/contact-verification/$contactId');
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    AppLogger.log(LogCategory.gui, "widgets/contacts_realtime/contacts_realtime.dart - _buildEmptyState: Showing empty state");
    String emptyText = _getEmptyStateText();
    log("widgets/contacts_realtime/contacts_realtime.dart - _buildEmptyState: Showing empty state: $emptyText");

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: emptyText,
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getSmall(context)),
          CustomText(
            text: I18nService().t('widgets_contacts.contacts_empty_state_text', fallback: 'Click the plus (+) to add a contact'),
            type: CustomTextType.small_bread,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateText() {
    switch (widget.sortType) {
      case ContactsSortType.firstName:
        return _searchQuery.isEmpty
            ? I18nService().t('widgets_contacts.contacts_empty_state_text_no_contacts_found', fallback: 'No contacts found')
            : I18nService().t('widgets_contacts.contacts_empty_state_text_no_contacts_found_search', fallback: 'No contacts found matching your search');
      case ContactsSortType.createdAt:
        return I18nService().t('widgets_contacts.contacts_empty_state_text_no_contacts_found', fallback: 'No contacts found');
      case ContactsSortType.starred:
        return I18nService().t('widgets_contacts.contacts_empty_state_text_no_contacts_found', fallback: 'No contacts found');
      case ContactsSortType.newest:
        return I18nService().t('widgets_contacts.contacts_empty_state_text_no_contacts_found', fallback: 'No contacts found');
    }
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    log("widgets/contacts_realtime/contacts_realtime.dart - _buildErrorWidget: Displaying error: $error");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          Gap(AppDimensionsTheme.getMedium(context)),
          CustomText(
            text: I18nService().t('widgets_contacts.contacts_error_text', fallback: 'Oops, an error occurred'),
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getSmall(context)),
          CustomButton(
            text: I18nService().t('widgets_contacts.contacts_error_button', fallback: 'Try again'),
            buttonType: CustomButtonType.primary,
            onPressed: () => _retryLoadContacts(),
          ),
          // SelectableText.rich(
          //   TextSpan(
          //     text: error.toString(),
          //     style: AppTheme.getBodyLarge(context)?.copyWith(
          //       color: Colors.red,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Created on 2025-01-26 10:30:00
// Modified on 2025-01-27 to add tabs functionality
