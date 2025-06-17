import '../exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/contacts_count_provider.g.dart';

@riverpod
class ContactsCountNotifier extends _$ContactsCountNotifier {
  static final log = scopedLogger(LogCategory.provider);
  late final ContactsCountService _contactsCountService;

  @override
  Future<int> build() async {
    _contactsCountService = ContactsCountService(ref.read(supabaseClientProvider));
    return _contactsCountService.getContactsCount();
  }

  Future<void> refreshCount() async {
    log('[providers/contacts_count_provider.dart][refreshCount] Refreshing contacts count');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _contactsCountService.getContactsCount());
  }
}

// File created: 2024-12-19 15:30:00
