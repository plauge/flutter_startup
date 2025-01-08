import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import 'supabase_service_provider.dart';

part 'generated/contacts_provider.g.dart';

@riverpod
class Contacts extends _$Contacts {
  @override
  Future<List<Contact>> build() async {
    print('\n=== Contacts build ===');
    final contacts = await ref.read(supabaseServiceProvider).loadContacts();
    print('Contacts loaded: ${contacts?.length ?? 0} items');
    return contacts ?? [];
  }

  Future<void> refresh() async {
    print('\n=== Contacts refresh ===');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final contacts = await ref.read(supabaseServiceProvider).loadContacts();
      print('Contacts refreshed: ${contacts?.length ?? 0} items');
      return contacts ?? [];
    });
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
