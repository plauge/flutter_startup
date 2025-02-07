import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/confirms_provider.dart';
import '../../models/confirm_state.dart';
import '../../models/api_response.dart';
import '../../models/confirm_payload.dart';
import 'initiator_widget.dart';
import 'confirm_success_widget.dart';
import 'confirm_existing_widget.dart';
import 'confirm_error_widget.dart';
import 'step_2.dart';
import 'step_3.dart';

class Confirm extends ConsumerStatefulWidget {
  final String contactId;

  const Confirm({
    super.key,
    required this.contactId,
  });

  @override
  ConsumerState<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends ConsumerState<Confirm> {
  ConfirmState currentState = ConfirmState.initial;
  ConfirmPayload? confirmData;
  String? errorMessage;

  void updateNewRecordStatus(bool newValue) {
    if (confirmData != null) {
      setState(() {
        confirmData = confirmData!.copyWith(newRecord: newValue);
      });
    }
  }

  void _handleStateChange(ConfirmState newState, Map<String, dynamic>? data) {
    debugPrint('🔍 _handleStateChange called with state: $newState');
    debugPrint('🔍 Raw data received: $data');

    setState(() {
      currentState = newState;
      if (data != null) {
        try {
          // Hvis det er en error, så skal vi udskrive errorMessage
          if (data['status_code'] == null || data['status_code'] != 200) {
            currentState = ConfirmState.error;
            errorMessage =
                data['message'] == null || data['message'].toString().isEmpty
                    ? 'Der skete en fejl'
                    : data['message'];
            return;
          }

          // Udpak payload fra response
          if (data['data'] != null && data['data']['payload'] != null) {
            final payload = data['data']['payload'] as Map<String, dynamic>;
            debugPrint('🔍 Extracted payload: $payload');

            final Map<String, dynamic> confirmData = {
              'confirms_id': payload['confirms_id'],
              'created_at': DateTime.now().toIso8601String(),
              'status': payload['status'],
              'contacts_id': widget.contactId,
              'question': payload['question'] ?? '',
            };

            // Kun sæt new_record hvis den er med i payload
            if (payload.containsKey('new_record')) {
              confirmData['new_record'] = payload['new_record'];
            } else if (this.confirmData != null) {
              // Behold eksisterende værdi hvis den findes
              confirmData['new_record'] = this.confirmData!.newRecord;
            }
            // Ellers bruges default værdien fra modellen (false)

            debugPrint('🔍 Prepared data for ConfirmPayload: $confirmData');
            this.confirmData = ConfirmPayload.fromJson(confirmData);
            debugPrint(
                '🔍 Successfully created ConfirmPayload: ${this.confirmData}');
            debugPrint('🔍 new_record value: ${this.confirmData?.newRecord}');

            // Her!
            debugPrint('🔍 🔍 🔍 🔍 TEST VALUES: 🔍 🔍 🔍 🔍');
            debugPrint('🔍 Status: ${this.confirmData?.status}');
            debugPrint('🔍 New Record: ${this.confirmData?.newRecord}');
            debugPrint('🔍 Full confirmData: ${this.confirmData?.toJson()}');

            if (this.confirmData?.status == 1 &&
                this.confirmData?.newRecord == true) {
              debugPrint('🔍 Setting state to step_2');
              currentState = ConfirmState.step_2;
            }

            if (this.confirmData?.status == 2 &&
                this.confirmData?.newRecord == false) {
              debugPrint('🔍 Setting state to step_3');
              currentState = ConfirmState.step_3;
            }
            // else {
            //   debugPrint(
            //       '🔍 Unexpected state combination - Status: ${this.confirmData?.status}, New Record: ${this.confirmData?.newRecord}');
            //   currentState = ConfirmState.error;
            //   errorMessage = 'Uventet tilstand';
            // }
          } else {
            throw Exception('Mangler payload data i svaret fra serveren');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error creating ConfirmPayload: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          currentState = ConfirmState.error;
          errorMessage = 'Kunne ikke behandle data: $e';
        }
      } else {
        debugPrint('❌ No data received, setting confirmData to null');
        confirmData = null;
      }
    });
    debugPrint('🔍 Final state: $currentState');
    debugPrint('🔍 Final confirmData: $confirmData');
    debugPrint('🔍 Final new_record value: ${confirmData?.newRecord}');
    debugPrint('🔍 Final errorMessage: $errorMessage');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🚩🚩🚩🚩 new_record: ${confirmData?.newRecord}');

    switch (currentState) {
      case ConfirmState.initial:
        return InitiatorWidget(
          contactId: widget.contactId,
          onStateChange: _handleStateChange,
        );
      case ConfirmState.step_2:
        return Step2Widget(
          rawData: confirmData!.toJson(),
          onStateChange: _handleStateChange,
        );
      case ConfirmState.step_3:
        return Step3Widget(
          rawData: confirmData!.toJson(),
          onStateChange: _handleStateChange,
        );
      case ConfirmState.error:
        return ConfirmErrorWidget(
          errorMessage: errorMessage ?? 'Der opstod en ukendt fejl',
          onStateChange: _handleStateChange,
        );
      default:
        return ConfirmErrorWidget(
          errorMessage: 'Ukendt tilstand',
          onStateChange: _handleStateChange,
        );
    }
  }
}
