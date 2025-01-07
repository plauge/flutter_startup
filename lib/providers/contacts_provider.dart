import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exports.dart';
import 'supabase_service_provider.dart';

final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(() {
  return ContactsNotifier();
});

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  @override
  Future<List<Contact>> build() async {
    print('\n=== ContactsNotifier build ===');
    final contacts = await ref.read(supabaseServiceProvider).loadContacts();
    print('Contacts loaded: ${contacts?.length ?? 0} items');
    return contacts ?? [];
  }

  Future<void> refresh() async {
    print('\n=== ContactsNotifier refresh ===');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final contacts = await ref.read(supabaseServiceProvider).loadContacts();
      print('Contacts refreshed: ${contacts?.length ?? 0} items');
      return contacts ?? [];
    });
  }
}
