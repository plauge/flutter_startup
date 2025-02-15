import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import 'supabase_service_provider.dart';
import './security_validation_provider.dart';

part 'generated/contacts_provider.g.dart';

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  @override
  FutureOr<List<Contact>> build() async {
    // Vent på security validation først
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      return [];
    }

    return _loadContacts();
  }

  Future<List<Contact>> _loadContacts() async {
    print('\n=== loadContacts Start ===');
    final contacts = await ref.read(supabaseServiceProvider).loadContacts();
    print('Contacts loaded: ${contacts?.length ?? 0} items');
    return contacts ?? [];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class StarredContacts extends _$StarredContacts {
  @override
  Future<List<Contact>> build() async {
    print('\n=== StarredContacts build ===');
    final contacts =
        await ref.read(supabaseServiceProvider).loadStarredContacts();
    print('Starred contacts loaded: ${contacts.length} items');
    return contacts;
  }

  Future<void> refresh() async {
    print('\n=== StarredContacts refresh ===');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final contacts =
          await ref.read(supabaseServiceProvider).loadStarredContacts();
      print('Starred contacts refreshed: ${contacts.length} items');
      return contacts;
    });
  }
}

@riverpod
class RecentContacts extends _$RecentContacts {
  @override
  Future<List<Contact>> build() async {
    print('\n=== RecentContacts build ===');
    final contacts =
        await ref.read(supabaseServiceProvider).loadRecentContacts();
    print('Recent contacts loaded: ${contacts.length} items');
    return contacts;
  }

  Future<void> refresh() async {
    print('\n=== RecentContacts refresh ===');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final contacts =
          await ref.read(supabaseServiceProvider).loadRecentContacts();
      print('Recent contacts refreshed: ${contacts.length} items');
      return contacts;
    });
  }
}

@riverpod
class NewContacts extends _$NewContacts {
  @override
  Future<List<Contact>> build() async {
    print('\n=== NewContacts build ===');
    final contacts = await ref.read(supabaseServiceProvider).loadNewContacts();
    print('New contacts loaded: ${contacts.length} items');
    return contacts;
  }

  Future<void> refresh() async {
    print('\n=== NewContacts refresh ===');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final contacts =
          await ref.read(supabaseServiceProvider).loadNewContacts();
      print('New contacts refreshed: ${contacts.length} items');
      return contacts;
    });
  }
}
