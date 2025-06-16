import '../exports.dart';

class PhoneCodeRealtimeService {
  final SupabaseClient _client;
  static final log = scopedLogger(LogCategory.service);

  PhoneCodeRealtimeService(this._client);

  Stream<List<PhoneCode>> watchPhoneCodes() {
    log('watchPhoneCodes: Setting up realtime stream for phone_codes_realtime table');

    return _client.from('phone_codes_realtime').stream(primaryKey: ['phone_codes_realtime_id']).order('created_at', ascending: false).map((data) {
          log('watchPhoneCodes: Received ${data.length} records from realtime stream');
          return data.map((item) => _mapToPhoneCode(item)).toList();
        });
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
      initiatorCancel: data['initiator_cancel'] ?? false,
      initiatorCancelUpdatedAt: data['initiator_cancel_updated_at'] != null ? DateTime.parse(data['initiator_cancel_updated_at']) : null,
      receiverRead: data['receiver_read'] ?? false,
      receiverReadUpdatedAt: data['receiver_read_updated_at'] != null ? DateTime.parse(data['receiver_read_updated_at']) : null,
    );
  }
}

// Created: 2025-01-16 16:30:00
