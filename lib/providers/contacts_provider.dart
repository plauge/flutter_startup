import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import 'supabase_service_provider.dart';
import './security_validation_provider.dart';
import './security_provider.dart';

part 'generated/contacts_provider.g.dart';

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  static final log = scopedLogger(LogCategory.provider);
  @override
  FutureOr<List<Contact>> build() async {
    log('Building ContactsNotifier');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, returning empty list');
      return [];
    }

    return _loadContacts();
  }

  Future<List<Contact>> _loadContacts() async {
    final stopwatch = Stopwatch()..start();
    log('Loading contacts...');
    try {
      final contacts = await ref.read(supabaseServiceProvider).loadContacts();
      log('Contacts loaded successfully', {'count': contacts?.length ?? 0, 'duration': '${stopwatch.elapsedMilliseconds}ms'});
      return contacts ?? [];
    } catch (e, st) {
      log('Error loading contacts', {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    log('Refreshing contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, triggering validation');
      final response = await ref.read(securityVerificationProvider.notifier).doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadContacts());
  }

  // void log(String message, [Map<String, dynamic>? data]) {
  //   final timestamp = DateTime.now().toIso8601String();
  //   final dataString = data != null ? ' Data: $data' : '';
  //   print('[$timestamp] ContactsNotifier: $message$dataString');
  // }
}

@riverpod
class StarredContacts extends _$StarredContacts {
  static final log = scopedLogger(LogCategory.provider);
  @override
  Future<List<Contact>> build() async {
    log('Building StarredContacts');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, returning empty list');
      return [];
    }
    return _loadStarredContacts();
  }

  Future<List<Contact>> _loadStarredContacts() async {
    final stopwatch = Stopwatch()..start();
    log('Loading starred contacts...');
    try {
      final contacts = await ref.read(supabaseServiceProvider).loadStarredContacts();
      log('Starred contacts loaded successfully', {'count': contacts.length, 'duration': '${stopwatch.elapsedMilliseconds}ms'});
      return contacts;
    } catch (e, st) {
      log('Error loading starred contacts', {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    log('Refreshing starred contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, triggering validation');
      final response = await ref.read(securityVerificationProvider.notifier).doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadStarredContacts());
  }

  // void log(String message, [Map<String, dynamic>? data]) {
  //   final timestamp = DateTime.now().toIso8601String();
  //   final dataString = data != null ? ' Data: $data' : '';
  //   print('[$timestamp] StarredContacts: $message$dataString');
  // }
}

@riverpod
class RecentContacts extends _$RecentContacts {
  static final log = scopedLogger(LogCategory.provider);
  @override
  Future<List<Contact>> build() async {
    log('Building RecentContacts');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, returning empty list');
      return [];
    }
    return _loadRecentContacts();
  }

  Future<List<Contact>> _loadRecentContacts() async {
    final stopwatch = Stopwatch()..start();
    log('Loading recent contacts...');
    try {
      final contacts = await ref.read(supabaseServiceProvider).loadRecentContacts();
      log('Recent contacts loaded successfully', {'count': contacts.length, 'duration': '${stopwatch.elapsedMilliseconds}ms'});
      return contacts;
    } catch (e, st) {
      log('Error loading recent contacts', {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    log('Refreshing recent contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, triggering validation');
      final response = await ref.read(securityVerificationProvider.notifier).doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadRecentContacts());
  }

  // void log(String message, [Map<String, dynamic>? data]) {
  //   final timestamp = DateTime.now().toIso8601String();
  //   final dataString = data != null ? ' Data: $data' : '';
  //   print('[$timestamp] RecentContacts: $message$dataString');
  // }
}

@riverpod
class NewContacts extends _$NewContacts {
  static final log = scopedLogger(LogCategory.provider);
  @override
  Future<List<Contact>> build() async {
    log('Building NewContacts');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, returning empty list');
      return [];
    }
    return _loadNewContacts();
  }

  Future<List<Contact>> _loadNewContacts() async {
    final stopwatch = Stopwatch()..start();
    log('Loading new contacts...');
    try {
      final contacts = await ref.read(supabaseServiceProvider).loadNewContacts();
      log('New contacts loaded successfully', {'count': contacts.length, 'duration': '${stopwatch.elapsedMilliseconds}ms'});

      return contacts;
    } catch (e, st) {
      log('Error loading new contacts', {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    log('Refreshing new contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      log('Security not validated, triggering validation');
      final response = await ref.read(securityVerificationProvider.notifier).doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadNewContacts());
  }

  // void log(String message, [Map<String, dynamic>? data]) {
  //   final timestamp = DateTime.now().toIso8601String();
  //   final dataString = data != null ? ' Data: $data' : '';
  //   print('[$timestamp] NewContacts: $message$dataString');
  // }
}
