import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';
import '../services/contacts_realtime_service.dart';
import 'supabase_service_provider.dart';

part 'generated/contacts_realtime_provider.g.dart';

@riverpod
ContactsRealtimeService contactsRealtimeService(ContactsRealtimeServiceRef ref) {
  final supabase = Supabase.instance.client;
  return ContactsRealtimeService(supabase);
}

@riverpod
class ContactsRealtimeNotifier extends _$ContactsRealtimeNotifier {
  static final log = scopedLogger(LogCategory.provider);

  @override
  Stream<List<ContactRealtime>> build() {
    log('[contacts_realtime_provider.dart][build] Starting contacts realtime stream');
    return ref.watch(contactsRealtimeServiceProvider).watchContactsRealtime();
  }

  Future<void> insertContact(ContactRealtime contact) async {
    try {
      log('[contacts_realtime_provider.dart][insertContact] Inserting contact: ${contact.firstName} ${contact.lastName}');
      await ref.read(contactsRealtimeServiceProvider).insertContactRealtime(contact);
    } catch (e) {
      log('[contacts_realtime_provider.dart][insertContact] Error: $e');
      rethrow;
    }
  }

  Future<void> updateContact(String contactsRealtimeId, Map<String, dynamic> updates) async {
    try {
      log('[contacts_realtime_provider.dart][updateContact] Updating contact: $contactsRealtimeId');
      await ref.read(contactsRealtimeServiceProvider).updateContactRealtime(contactsRealtimeId, updates);
    } catch (e) {
      log('[contacts_realtime_provider.dart][updateContact] Error: $e');
      rethrow;
    }
  }

  Future<void> deleteContact(String contactsRealtimeId) async {
    try {
      log('[contacts_realtime_provider.dart][deleteContact] Deleting contact: $contactsRealtimeId');
      await ref.read(contactsRealtimeServiceProvider).deleteContactRealtime(contactsRealtimeId);
    } catch (e) {
      log('[contacts_realtime_provider.dart][deleteContact] Error: $e');
      rethrow;
    }
  }

  Future<void> toggleStar(String contactsRealtimeId, bool star) async {
    try {
      log('[contacts_realtime_provider.dart][toggleStar] Toggling star for: $contactsRealtimeId to $star');
      await ref.read(contactsRealtimeServiceProvider).toggleStar(contactsRealtimeId, star);
    } catch (e) {
      log('[contacts_realtime_provider.dart][toggleStar] Error: $e');
      rethrow;
    }
  }
}

@riverpod
class ContactsRealtimeListNotifier extends _$ContactsRealtimeListNotifier {
  static final log = scopedLogger(LogCategory.provider);

  @override
  Future<List<ContactRealtime>> build() async {
    log('[contacts_realtime_provider.dart][build] Loading contacts realtime list');
    return ref.watch(contactsRealtimeServiceProvider).getContactsRealtime();
  }

  Future<void> refresh() async {
    log('[contacts_realtime_provider.dart][refresh] Refreshing contacts realtime list');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(contactsRealtimeServiceProvider).getContactsRealtime());
  }
}

// Created on 2025-01-26 10:30:00
