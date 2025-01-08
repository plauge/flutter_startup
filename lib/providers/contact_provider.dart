import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../exports.dart';
import '../models/contact.dart';
import '../services/supabase_service_contact.dart';

part 'generated/contact_provider.g.dart';

@riverpod
class ContactNotifier extends AutoDisposeAsyncNotifier<Contact?> {
  @override
  FutureOr<Contact?> build() => null;

  Future<bool> checkContactExists(String contactId) async {
    state = const AsyncValue.loading();
    try {
      final exists = await ref
          .read(supabaseServiceContactProvider)
          .checkContactExists(contactId);
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
      final contact =
          await ref.read(supabaseServiceContactProvider).loadContact(contactId);
      state = AsyncValue.data(contact);
    } catch (e, st) {
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
      print('Provider: Toggling star for contact: $contactId');
      final success =
          await ref.read(supabaseServiceContactProvider).toggleStar(contactId);
      print('Provider: Toggle star API call success: $success');
      if (success && state.hasValue && state.value != null) {
        print(
            'Provider: Updating local state, current star value: ${state.value!.star}');
        state =
            AsyncValue.data(state.value!.copyWith(star: !state.value!.star));
        print('Provider: State updated, new star value: ${state.value!.star}');
      }
    } catch (e, st) {
      print('Provider: Error in toggleStar: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
SupabaseServiceContact supabaseServiceContact(SupabaseServiceContactRef ref) {
  return SupabaseServiceContact(Supabase.instance.client);
}
