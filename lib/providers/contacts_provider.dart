import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';
import 'supabase_service_provider.dart';
import './security_validation_provider.dart';
import './security_provider.dart';

part 'generated/contacts_provider.g.dart';

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  @override
  FutureOr<List<Contact>> build() async {
    _log('Building ContactsNotifier');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, returning empty list');
      return [];
    }

    return _loadContacts();
  }

  Future<List<Contact>> _loadContacts() async {
    final stopwatch = Stopwatch()..start();
    _log('Loading contacts...');
    try {
      final contacts = await ref.read(supabaseServiceProvider).loadContacts();
      _log('Contacts loaded successfully', {
        'count': contacts?.length ?? 0,
        'duration': '${stopwatch.elapsedMilliseconds}ms'
      });
      return contacts ?? [];
    } catch (e, st) {
      _log('Error loading contacts',
          {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    _log('Refreshing contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, triggering validation');
      final response = await ref
          .read(securityVerificationProvider.notifier)
          .doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          _log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadContacts());
  }

  void _log(String message, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String();
    final dataString = data != null ? ' Data: $data' : '';
    print('[$timestamp] ContactsNotifier: $message$dataString');
  }
}

@riverpod
class StarredContacts extends _$StarredContacts {
  @override
  Future<List<Contact>> build() async {
    _log('Building StarredContacts');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, returning empty list');
      return [];
    }
    return _loadStarredContacts();
  }

  Future<List<Contact>> _loadStarredContacts() async {
    final stopwatch = Stopwatch()..start();
    _log('Loading starred contacts...');
    try {
      final contacts =
          await ref.read(supabaseServiceProvider).loadStarredContacts();
      _log('Starred contacts loaded successfully', {
        'count': contacts.length,
        'duration': '${stopwatch.elapsedMilliseconds}ms'
      });
      return contacts;
    } catch (e, st) {
      _log('Error loading starred contacts',
          {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    _log('Refreshing starred contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, triggering validation');
      final response = await ref
          .read(securityVerificationProvider.notifier)
          .doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          _log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadStarredContacts());
  }

  void _log(String message, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String();
    final dataString = data != null ? ' Data: $data' : '';
    print('[$timestamp] StarredContacts: $message$dataString');
  }
}

@riverpod
class RecentContacts extends _$RecentContacts {
  @override
  Future<List<Contact>> build() async {
    _log('Building RecentContacts');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, returning empty list');
      return [];
    }
    return _loadRecentContacts();
  }

  Future<List<Contact>> _loadRecentContacts() async {
    final stopwatch = Stopwatch()..start();
    _log('Loading recent contacts...');
    try {
      final contacts =
          await ref.read(supabaseServiceProvider).loadRecentContacts();
      _log('Recent contacts loaded successfully', {
        'count': contacts.length,
        'duration': '${stopwatch.elapsedMilliseconds}ms'
      });
      return contacts;
    } catch (e, st) {
      _log('Error loading recent contacts',
          {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    _log('Refreshing recent contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, triggering validation');
      final response = await ref
          .read(securityVerificationProvider.notifier)
          .doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          _log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadRecentContacts());
  }

  void _log(String message, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String();
    final dataString = data != null ? ' Data: $data' : '';
    print('[$timestamp] RecentContacts: $message$dataString');
  }
}

@riverpod
class NewContacts extends _$NewContacts {
  @override
  Future<List<Contact>> build() async {
    _log('Building NewContacts');
    final isSecurityValidated = ref.watch(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, returning empty list');
      return [];
    }
    return _loadNewContacts();
  }

  Future<List<Contact>> _loadNewContacts() async {
    final stopwatch = Stopwatch()..start();
    _log('Loading new contacts...');
    try {
      final contacts =
          await ref.read(supabaseServiceProvider).loadNewContacts();
      _log('New contacts loaded successfully', {
        'count': contacts.length,
        'duration': '${stopwatch.elapsedMilliseconds}ms'
      });
      return contacts;
    } catch (e, st) {
      _log('Error loading new contacts',
          {'error': e.toString(), 'stackTrace': st.toString()});
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> refresh() async {
    _log('Refreshing new contacts');
    state = const AsyncValue.loading();

    final isSecurityValidated = ref.read(securityValidationNotifierProvider);
    if (!isSecurityValidated) {
      _log('Security not validated, triggering validation');
      final response = await ref
          .read(securityVerificationProvider.notifier)
          .doCaretaking(AppVersionConstants.appVersionInt.toString());
      if (response.isNotEmpty) {
        final firstResponse = response.first;
        final data = firstResponse['data'] as Map<String, dynamic>;
        final payload = data['payload'] as String;
        if (payload.toLowerCase() == 'ok') {
          _log('Security validation successful, setting validated state');
          ref.read(securityValidationNotifierProvider.notifier).setValidated();
        }
      }
    }

    state = await AsyncValue.guard(() => _loadNewContacts());
  }

  void _log(String message, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String();
    final dataString = data != null ? ' Data: $data' : '';
    print('[$timestamp] NewContacts: $message$dataString');
  }
}
