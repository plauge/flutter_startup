import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../exports.dart';

class ConfirmsRealtimeService {
  static final log = scopedLogger(LogCategory.service);
  final SupabaseClient _supabase;
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  ConfirmsRealtimeService(this._supabase);

  /// Fetches specific confirms_realtime record for given confirms_id
  Future<ConfirmsRealtime?> getConfirmsRealtime(String confirmsId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        log('[confirms_realtime_service.dart][getConfirmsRealtime] No authenticated user');
        return null;
      }

      log('[confirms_realtime_service.dart][getConfirmsRealtime] Loading confirms_realtime for confirms_id: $confirmsId');

      final response = await _supabase.from('confirms_realtime').select('*').eq('confirms_id', confirmsId).maybeSingle();

      if (response == null) {
        log('[confirms_realtime_service.dart][getConfirmsRealtime] No record found');
        return null;
      }

      log('[confirms_realtime_service.dart][getConfirmsRealtime] Record found: $response');
      return ConfirmsRealtime.fromJson(response);
    } catch (e, stack) {
      log('[confirms_realtime_service.dart][getConfirmsRealtime] Error: $e, Stack: $stack');
      throw Exception('Failed to load confirms realtime: $e');
    }
  }

  /// Creates a realtime stream for specific confirms_id
  Stream<ConfirmsRealtime?> watchConfirmsRealtime(String confirmsId) {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      log('[confirms_realtime_service.dart][watchConfirmsRealtime] No authenticated user');
      return Stream.value(null);
    }

    log('[confirms_realtime_service.dart][watchConfirmsRealtime] Starting realtime stream for confirms_id: $confirmsId');

    return _supabase.from('confirms_realtime').stream(primaryKey: ['confirms_realtime_id']).eq('confirms_id', confirmsId).map((data) {
          log('[confirms_realtime_service.dart][watchConfirmsRealtime] Realtime update received: ${data.length} items');
          if (data.isEmpty) return null;
          return ConfirmsRealtime.fromJson(data.first);
        });
  }

  /// Disposes the service and cancels subscriptions
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    log('[confirms_realtime_service.dart][dispose] Service disposed');
  }
}

// Created on 2025-01-27 at 13:45:00
