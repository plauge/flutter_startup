import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';

class ContactsRealtimeService {
  static final log = scopedLogger(LogCategory.service);
  final SupabaseClient _supabase;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  ContactsRealtimeService(this._supabase);

  /// Fetches all contacts_realtime for the current user
  Future<List<ContactRealtime>> getContactsRealtime() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        log('[contacts_realtime_service.dart][getContactsRealtime] No authenticated user');
        return [];
      }

      log('[contacts_realtime_service.dart][getContactsRealtime] Loading contacts_realtime for user: ${user.id}');

      final response = await _supabase.from('contacts_realtime').select('*').eq('user_id', user.id).order('created_at', ascending: false);

      log('[contacts_realtime_service.dart][getContactsRealtime] Response received: ${response.length} items');

      return response.map((json) => ContactRealtime.fromJson(json)).toList();
    } catch (e, stack) {
      log('[contacts_realtime_service.dart][getContactsRealtime] Error: $e, Stack: $stack');
      throw Exception('Failed to load contacts realtime: $e');
    }
  }

  /// Creates a realtime stream for contacts_realtime
  Stream<List<ContactRealtime>> watchContactsRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      log('[contacts_realtime_service.dart][watchContactsRealtime] No authenticated user');
      return Stream.value([]);
    }

    log('[contacts_realtime_service.dart][watchContactsRealtime] Starting realtime stream for user: ${user.id}');

    return _supabase.from('contacts_realtime').stream(primaryKey: ['contacts_realtime_id']).eq('user_id', user.id).order('created_at', ascending: false).map((data) {
          log('[contacts_realtime_service.dart][watchContactsRealtime] Realtime update received: ${data.length} items');
          return data.map((json) => ContactRealtime.fromJson(json)).toList();
        });
  }

  // TODO: Commented out 2026-02-19. Not used from GUI - can be deleted in a few weeks.
  // /// Inserts a new contact_realtime record
  // Future<void> insertContactRealtime(ContactRealtime contact) async {
  //   try {
  //     final user = _supabase.auth.currentUser;
  //     if (user == null) {
  //       throw Exception('No authenticated user');
  //     }
  //
  //     log('[contacts_realtime_service.dart][insertContactRealtime] Inserting contact: ${contact.firstName} ${contact.lastName}');
  //
  //     await _supabase.from('contacts_realtime').insert(contact.toJson());
  //
  //     log('[contacts_realtime_service.dart][insertContactRealtime] Contact inserted successfully');
  //   } catch (e, stack) {
  //     log('[contacts_realtime_service.dart][insertContactRealtime] Error: $e, Stack: $stack');
  //     throw Exception('Failed to insert contact realtime: $e');
  //   }
  // }
  //
  // /// Updates an existing contact_realtime record
  // Future<void> updateContactRealtime(String contactsRealtimeId, Map<String, dynamic> updates) async {
  //   try {
  //     final user = _supabase.auth.currentUser;
  //     if (user == null) {
  //       throw Exception('No authenticated user');
  //     }
  //
  //     log('[contacts_realtime_service.dart][updateContactRealtime] Updating contact: $contactsRealtimeId');
  //
  //     await _supabase.from('contacts_realtime').update(updates).eq('contacts_realtime_id', contactsRealtimeId).eq('user_id', user.id);
  //
  //     log('[contacts_realtime_service.dart][updateContactRealtime] Contact updated successfully');
  //   } catch (e, stack) {
  //     log('[contacts_realtime_service.dart][updateContactRealtime] Error: $e, Stack: $stack');
  //     throw Exception('Failed to update contact realtime: $e');
  //   }
  // }
  //
  // /// Deletes a contact_realtime record
  // Future<void> deleteContactRealtime(String contactsRealtimeId) async {
  //   try {
  //     final user = _supabase.auth.currentUser;
  //     if (user == null) {
  //       throw Exception('No authenticated user');
  //     }
  //
  //     log('[contacts_realtime_service.dart][deleteContactRealtime] Deleting contact: $contactsRealtimeId');
  //
  //     await _supabase.from('contacts_realtime').delete().eq('contacts_realtime_id', contactsRealtimeId).eq('user_id', user.id);
  //
  //     log('[contacts_realtime_service.dart][deleteContactRealtime] Contact deleted successfully');
  //   } catch (e, stack) {
  //     log('[contacts_realtime_service.dart][deleteContactRealtime] Error: $e, Stack: $stack');
  //     throw Exception('Failed to delete contact realtime: $e');
  //   }
  // }
  //
  // /// Toggles star status for a contact
  // Future<void> toggleStar(String contactsRealtimeId, bool star) async {
  //   try {
  //     await updateContactRealtime(contactsRealtimeId, {'star': star});
  //     log('[contacts_realtime_service.dart][toggleStar] Star toggled to: $star');
  //   } catch (e) {
  //     log('[contacts_realtime_service.dart][toggleStar] Error: $e');
  //     rethrow;
  //   }
  // }

  /// Disposes the service and cancels subscriptions
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    log('[contacts_realtime_service.dart][dispose] Service disposed');
  }
}

// Created on 2025-01-26 10:30:00
