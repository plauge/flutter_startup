import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/phone_code_realtime_service.dart';
import '../exports.dart';

part 'generated/phone_code_realtime_provider.g.dart';

@riverpod
PhoneCodeRealtimeService phoneCodeRealtimeService(PhoneCodeRealtimeServiceRef ref) {
  return PhoneCodeRealtimeService(Supabase.instance.client);
}

@riverpod
Stream<List<PhoneCode>> phoneCodesRealtimeStream(PhoneCodesRealtimeStreamRef ref) {
  final service = ref.watch(phoneCodeRealtimeServiceProvider);
  return service.watchPhoneCodes();
}

// Created: 2025-01-16 16:30:00
