import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../exports.dart';
import '../models/contact.dart';
import '../services/supabase_service_contact.dart';

part 'generated/contact_provider.g.dart';

@riverpod
class ContactNotifier extends AutoDisposeAsyncNotifier<Contact?> {
  static final log = scopedLogger(LogCategory.provider);
  @override
  FutureOr<Contact?> build() => null;

  Future<bool> checkContactExists(String contactId) async {
    state = const AsyncValue.loading();
    try {
      final exists = await ref.read(supabaseServiceContactProvider).checkContactExists(contactId);
      if (!exists) {
        state = const AsyncValue.data(null);
        return false;
      }
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> loadContact(String contactId) async {
    state = const AsyncValue.loading();
    try {
      final contact = await ref.read(supabaseServiceContactProvider).loadContact(contactId);
      state = AsyncValue.data(contact);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadContactLight(String contactId) async {
    log('loadContactLight: Starting to load contact with ID: $contactId');
    state = const AsyncValue.loading();
    try {
      log('loadContactLight: Calling supabase service for contactId: $contactId');
      final contact = await ref.read(supabaseServiceContactProvider).loadContactLight(contactId);
      log('loadContactLight: Received contact data: ${contact?.toJson()}');
      state = AsyncValue.data(contact);
      log('loadContactLight: State updated with contact data');
    } catch (e, st) {
      log('loadContactLight: Error occurred: $e');
      log('loadContactLight: Stack trace: $st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsVisited(String contactId) async {
    try {
      await ref.read(supabaseServiceContactProvider).markAsVisited(contactId);
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> toggleStar(String contactId) async {
    try {
      log('Provider: Toggling star for contact: $contactId');
      final success = await ref.read(supabaseServiceContactProvider).toggleStar(contactId);
      log('Provider: Toggle star API call success: $success');
      if (success && state.hasValue && state.value != null) {
        log('Provider: Updating local state, current star value: ${state.value!.star}');
        state = AsyncValue.data(state.value!.copyWith(star: !state.value!.star));
        log('Provider: State updated, new star value: ${state.value!.star}');
      }
    } catch (e, st) {
      log('Provider: Error in toggleStar: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> deleteContact(String contactId) async {
    try {
      final success = await ref.read(supabaseServiceContactProvider).deleteContact(contactId);
      if (success) {
        state = const AsyncValue.data(null);
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

@riverpod
SupabaseServiceContact supabaseServiceContact(SupabaseServiceContactRef ref) {
  return SupabaseServiceContact(Supabase.instance.client);
}
