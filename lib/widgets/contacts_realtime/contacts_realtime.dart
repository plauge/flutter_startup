import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../exports.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Fjern focus fra alle input felter og luk keyboardet
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.all(AppDimensionsTheme.getMedium(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Realtime Contacts',
              type: CustomTextType.head,
            ),
            Gap(AppDimensionsTheme.getSmall(context)),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Recent'),
                Tab(text: 'Star'),
                Tab(text: 'New'),
              ],
            ),
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
}

enum ContactsSortType {
  firstName,
  createdAt,
  starred,
  newest,
}

class _ContactsTabView extends ConsumerWidget {
  static final log = scopedLogger(LogCategory.gui);
  final ContactsSortType sortType;

  const _ContactsTabView({required this.sortType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsStream = ref.watch(contactsRealtimeNotifierProvider);

    return contactsStream.when(
      data: (contacts) => _buildContactsList(context, ref, contacts),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(context, error),
    );
  }

  Widget _buildContactsList(BuildContext context, WidgetRef ref, List<ContactRealtime> contacts) {
    // Filter and sort contacts based on tab type
    List<ContactRealtime> filteredContacts = _filterAndSortContacts(contacts);

    if (filteredContacts.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
        return _buildContactTile(context, ref, contact);
      },
    );
  }

  List<ContactRealtime> _filterAndSortContacts(List<ContactRealtime> contacts) {
    List<ContactRealtime> filtered = List.from(contacts);

    switch (sortType) {
      case ContactsSortType.firstName:
        // Sort by first name alphabetically
        filtered.sort((a, b) {
          final aName = a.firstName ?? '';
          final bName = b.firstName ?? '';
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        break;
      case ContactsSortType.createdAt:
        // Sort by created_at (recent first)
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
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
        break;
      case ContactsSortType.newest:
        // Sort by created_at (newest first)
        filtered.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }

    return filtered;
  }

  Widget _buildContactTile(BuildContext context, WidgetRef ref, ContactRealtime contact) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensionsTheme.getSmall(context)),
      color: contact.contactType < 0 ? Colors.lightBlue[50] : null,
      child: ListTile(
        leading: _buildAvatar(contact),
        title: CustomText(
          text: '${contact.firstName ?? ''} ${contact.lastName ?? ''}',
          type: CustomTextType.info,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.email?.isNotEmpty == true) ...[
              Gap(AppDimensionsTheme.getSmall(context) / 2),
              CustomText(
                text: contact.email!,
                type: CustomTextType.small_bread,
              ),
            ],
            if (contact.company?.isNotEmpty == true) ...[
              Gap(AppDimensionsTheme.getSmall(context) / 2),
              CustomText(
                text: contact.company!,
                type: CustomTextType.small_bread,
              ),
            ],
            Gap(AppDimensionsTheme.getSmall(context) / 2),
            CustomText(
              text: 'Type: ${contact.contactType}',
              type: CustomTextType.small_bread,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                contact.star ? Icons.star : Icons.star_border,
                color: contact.star ? Colors.amber : Colors.grey,
              ),
              onPressed: () => _toggleStar(ref, contact),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, contact, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ContactRealtime contact) {
    if (contact.profileImage.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(contact.profileImage),
        radius: 20,
      );
    }

    final initials = _getInitials(contact);
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.blue[100],
      child: CustomText(
        text: initials,
        type: CustomTextType.info,
      ),
    );
  }

  String _getInitials(ContactRealtime contact) {
    final firstName = contact.firstName ?? '';
    final lastName = contact.lastName ?? '';

    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }

    return initials.isEmpty ? '?' : initials;
  }

  Widget _buildEmptyState(BuildContext context) {
    String emptyText = _getEmptyStateText();

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
          const CustomText(
            text: 'Contacts will appear here in real-time',
            type: CustomTextType.small_bread,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateText() {
    switch (sortType) {
      case ContactsSortType.firstName:
        return 'No contacts found';
      case ContactsSortType.createdAt:
        return 'No recent contacts found';
      case ContactsSortType.starred:
        return 'No starred contacts found';
      case ContactsSortType.newest:
        return 'No new contacts found';
    }
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
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
          const CustomText(
            text: 'Error loading contacts',
            type: CustomTextType.bread,
          ),
          Gap(AppDimensionsTheme.getSmall(context)),
          SelectableText.rich(
            TextSpan(
              text: error.toString(),
              style: AppTheme.getBodyLarge(context)?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStar(WidgetRef ref, ContactRealtime contact) async {
    try {
      log('[contacts_realtime.dart][_toggleStar] Toggling star for contact: ${contact.contactsRealtimeId}');
      await ref.read(contactsRealtimeNotifierProvider.notifier).toggleStar(contact.contactsRealtimeId, !contact.star);
    } catch (e) {
      log('[contacts_realtime.dart][_toggleStar] Error: $e');
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, ContactRealtime contact, String action) {
    switch (action) {
      case 'edit':
        _showEditDialog(context, ref, contact);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, contact);
        break;
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, ContactRealtime contact) {
    // TODO: Implement edit dialog
    log('[contacts_realtime.dart][_showEditDialog] Edit dialog for: ${contact.contactsRealtimeId}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality not implemented yet')),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ContactRealtime contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const CustomText(
            text: 'Delete Contact',
            type: CustomTextType.info,
          ),
          content: CustomText(
            text: 'Are you sure you want to delete ${contact.firstName} ${contact.lastName}?',
            type: CustomTextType.bread,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const CustomText(
                text: 'Cancel',
                type: CustomTextType.button,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteContact(ref, contact);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const CustomText(
                text: 'Delete',
                type: CustomTextType.button,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteContact(WidgetRef ref, ContactRealtime contact) async {
    try {
      log('[contacts_realtime.dart][_deleteContact] Deleting contact: ${contact.contactsRealtimeId}');
      await ref.read(contactsRealtimeNotifierProvider.notifier).deleteContact(contact.contactsRealtimeId);
    } catch (e) {
      log('[contacts_realtime.dart][_deleteContact] Error: $e');
    }
  }
}

// Created on 2025-01-26 10:30:00
// Modified on 2025-01-27 to add tabs functionality
