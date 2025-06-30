import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';
import '../services/confirms_realtime_service.dart';

part 'generated/confirms_realtime_provider.g.dart';

@riverpod
ConfirmsRealtimeService confirmsRealtimeService(ConfirmsRealtimeServiceRef ref) {
  final supabase = Supabase.instance.client;
  return ConfirmsRealtimeService(supabase);
}

@riverpod
class ConfirmsRealtimeNotifier extends _$ConfirmsRealtimeNotifier {
  static final log = scopedLogger(LogCategory.provider);

  @override
  Stream<ConfirmsRealtime?> build(String confirmsId) {
    log('[confirms_realtime_provider.dart][build] Starting confirms realtime stream for confirms_id: $confirmsId');
    return ref.watch(confirmsRealtimeServiceProvider).watchConfirmsRealtime(confirmsId);
  }

  Future<ConfirmsRealtime?> getConfirmsRealtime(String confirmsId) async {
    try {
      log('[confirms_realtime_provider.dart][getConfirmsRealtime] Getting confirms realtime for confirms_id: $confirmsId');
      return await ref.read(confirmsRealtimeServiceProvider).getConfirmsRealtime(confirmsId);
    } catch (e) {
      log('[confirms_realtime_provider.dart][getConfirmsRealtime] Error: $e');
      rethrow;
    }
  }
}

// Created on 2025-01-27 at 13:45:00
