import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../exports.dart';

part 'generated/phone_code_realtime_provider.g.dart';

@riverpod
PhoneCodeRealtimeService phoneCodeRealtimeService(PhoneCodeRealtimeServiceRef ref) {
  final service = PhoneCodeRealtimeService(Supabase.instance.client);

  // Ensure service is disposed when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@riverpod
Stream<List<PhoneCode>> phoneCodesRealtimeStream(PhoneCodesRealtimeStreamRef ref) {
  final service = ref.watch(phoneCodeRealtimeServiceProvider);
  return service.watchPhoneCodes();
}

// Created: 2025-01-16 16:30:00
