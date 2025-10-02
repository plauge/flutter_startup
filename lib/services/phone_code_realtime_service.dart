import '../exports.dart';
import 'dart:async';

class PhoneCodeRealtimeService {
  final SupabaseClient _client;
  static final log = scopedLogger(LogCategory.service);

  // Stream controller for manual refresh capability
  StreamController<List<PhoneCode>>? _streamController;
  StreamSubscription? _supabaseSubscription;
  bool _isDisposed = false;

  PhoneCodeRealtimeService(this._client);

  Stream<List<PhoneCode>> watchPhoneCodes() {
    log('watchPhoneCodes: Setting up robust realtime stream for phone_codes_realtime table');

    // Create a new stream controller if needed
    if (_streamController == null || _streamController!.isClosed) {
      _streamController = StreamController<List<PhoneCode>>.broadcast();
      _setupRealtimeStream();

      // Register with connection service for automatic refresh
      RealtimeConnectionService.instance.registerRefreshCallback(_refreshStream);
    }

    return _streamController!.stream;
  }

  /// Setup the actual Supabase realtime stream
  void _setupRealtimeStream() {
    if (_isDisposed) return;

    log('_setupRealtimeStream: Creating new Supabase stream subscription');

    // Cancel existing subscription
    _supabaseSubscription?.cancel();

    // Check authentication
    final user = _client.auth.currentUser;
    if (user == null) {
      log('_setupRealtimeStream: No authenticated user - providing empty stream');
      if (!_streamController!.isClosed) {
        _streamController!.add([]);
      }
      return;
    }

    try {
      // Create new subscription with error handling
      _supabaseSubscription = _client.from('phone_codes_realtime').stream(primaryKey: ['phone_codes_realtime_id']).order('created_at', ascending: false).listen(
            (data) {
              if (_isDisposed || _streamController!.isClosed) return;

              log('_setupRealtimeStream: Received ${data.length} records from realtime stream');
              final phoneCodes = data.map((item) => _mapToPhoneCode(item)).toList();
              _streamController!.add(phoneCodes);
            },
            onError: (error) {
              if (_isDisposed || _streamController!.isClosed) return;

              log('_setupRealtimeStream: Stream error occurred: $error');
              _streamController!.addError(error);

              // Schedule reconnection after error
              _scheduleReconnection();
            },
            onDone: () {
              log('_setupRealtimeStream: Stream completed unexpectedly - scheduling reconnection');
              if (!_isDisposed) {
                _scheduleReconnection();
              }
            },
          );
    } catch (e) {
      log('_setupRealtimeStream: Error setting up stream: $e');
      if (!_streamController!.isClosed) {
        _streamController!.addError(e);
      }
      _scheduleReconnection();
    }
  }

  /// Refresh the stream (called by RealtimeConnectionService)
  void _refreshStream() {
    if (_isDisposed) return;

    log('_refreshStream: Manually refreshing phone codes realtime stream');
    _setupRealtimeStream();
  }

  /// Schedule reconnection after a delay
  void _scheduleReconnection() {
    if (_isDisposed) return;

    log('_scheduleReconnection: Scheduling stream reconnection in 3 seconds');

    Future.delayed(const Duration(seconds: 3), () {
      if (!_isDisposed && _streamController != null && !_streamController!.isClosed) {
        log('_scheduleReconnection: Executing scheduled reconnection');
        _setupRealtimeStream();
      }
    });
  }

  /// Dispose of resources
  void dispose() {
    log('dispose: Disposing PhoneCodeRealtimeService resources');
    _isDisposed = true;

    // Unregister from connection service
    RealtimeConnectionService.instance.unregisterRefreshCallback(_refreshStream);

    // Cancel subscriptions
    _supabaseSubscription?.cancel();
    _supabaseSubscription = null;

    // Close stream controller
    _streamController?.close();
    _streamController = null;
  }

  PhoneCode _mapToPhoneCode(Map<String, dynamic> data) {
    return PhoneCode(
      phoneCodesId: data['phone_codes_id'],
      createdAt: DateTime.parse(data['phone_codes_created_at']),
      updatedAt: DateTime.parse(data['phone_codes_updated_at']),
      customerUserId: data['customer_user_id'],
      receiverUserId: data['receiver_user_id'],
      customerEmployeeId: data['customer_employee_id'],
      initiatorInfo: data['initiator_info'],
      confirmCode: data['confirm_code'],
      phoneCodesType: data['phone_codes_type'] ?? 'customer', // Tilføjet det nye required felt med fallback
      initiatorCancel: data['initiator_cancel'] ?? false,
      initiatorCancelUpdatedAt: data['initiator_cancel_updated_at'] != null ? DateTime.parse(data['initiator_cancel_updated_at']) : null,
      receiverRead: data['receiver_read'] ?? false,
      receiverReadUpdatedAt: data['receiver_read_updated_at'] != null ? DateTime.parse(data['receiver_read_updated_at']) : null,
    );
  }
}

// Created: 2025-01-16 16:30:00
