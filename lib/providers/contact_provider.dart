import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../exports.dart';
import '../services/supabase_service_contact.dart';
import '../providers/supabase_service_provider.dart';

part 'generated/contact_provider.g.dart';

@riverpod
class Contact extends _$Contact {
  @override
  FutureOr<void> build() {}

  Future<void> markAsVisited(String contactId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseServiceProvider);
      final contactService = SupabaseServiceContact(supabase.client);
      await contactService.markContactAsVisited(contactId);
    });
  }

  Future<bool> checkContactExists(String contactId) async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseServiceProvider);
      final contactService = SupabaseServiceContact(supabase.client);
      final exists = await contactService.contactExists(contactId);
      state = const AsyncData(null);
      return exists;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}
